import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
} from '@nestjs/common';
import { QueryFailedError, Repository } from 'typeorm';
import { ReportService } from './report.service';
import { Report } from './entities/report.entity';
import { ProfileColab } from '../profile-colab/entities/profile-colab.entity';
import { ServiceRequest } from '../service-request/entities/service-request.entity';
import { ServiceRequestStatus } from 'src/common/enums/service-request-status.enum';
import { ProposalStatus } from 'src/common/enums/proposal-status.enum';
import { CreateReportDto } from './dto/create-report.dto';

interface ReportRepoMock {
  findOne: jest.Mock<Promise<Report | null>, [unknown]>;
  create: jest.Mock<Report, [Partial<Report>]>;
  save: jest.Mock<Promise<Report>, [Report]>;
}

interface ProfileColabRepoMock {
  findOne: jest.Mock<Promise<ProfileColab | null>, [unknown]>;
}

interface ServiceRequestRepoMock {
  findOne: jest.Mock<Promise<ServiceRequest | null>, [unknown]>;
}

describe('ReportService.create', () => {
  let reportRepository: ReportRepoMock;
  let profileColabRepository: ProfileColabRepoMock;
  let serviceRequestRepository: ServiceRequestRepoMock;
  let service: ReportService;

  const reporterId = 'reporter-1';
  const winnerUserId = 'colab-1';

  const validServiceRequest = () =>
    ({
      id: 'sr-1',
      userId: reporterId,
      status: ServiceRequestStatus.CANCELLED,
      profileColabId: undefined,
      profileColab: undefined,
      proposals: [
        {
          status: ProposalStatus.ACCEPTED,
          profileColabId: 'pc-1',
          profileColab: { userId: winnerUserId },
        },
      ],
    }) as unknown as ServiceRequest;

  const baseDto: CreateReportDto = {
    serviceRequestId: 'sr-1',
    category: 'comportamiento_inapropiado',
    description: 'Prueba',
  };

  beforeEach(() => {
    reportRepository = {
      findOne: jest
        .fn<Promise<Report | null>, [unknown]>()
        .mockResolvedValue(null),
      create: jest.fn<Report, [Partial<Report>]>((data) => data as Report),
      save: jest.fn<Promise<Report>, [Report]>((data) =>
        Promise.resolve({ id: 'report-1', ...data }),
      ),
    };
    profileColabRepository = {
      findOne: jest.fn<Promise<ProfileColab | null>, [unknown]>(),
    };
    serviceRequestRepository = {
      findOne: jest
        .fn<Promise<ServiceRequest | null>, [unknown]>()
        .mockResolvedValue(validServiceRequest()),
    };

    service = new ReportService(
      reportRepository as unknown as Repository<Report>,
      profileColabRepository as unknown as Repository<ProfileColab>,
      serviceRequestRepository as unknown as Repository<ServiceRequest>,
    );
  });

  it('deriva el usuario reportado del ganador e ignora los datos del cliente', async () => {
    const dto: CreateReportDto = {
      ...baseDto,
      reportedUserId: 'fake-user',
      profileColabId: 'fake-pc',
    };

    await service.create(reporterId, dto);

    expect(profileColabRepository.findOne).not.toHaveBeenCalled();
    expect(reportRepository.create).toHaveBeenCalledWith(
      expect.objectContaining({ reportedUserId: winnerUserId }),
    );
  });

  it('rechaza con Conflict un segundo reporte del mismo servicio', async () => {
    reportRepository.findOne.mockResolvedValueOnce({
      id: 'report-existing',
    } as Report);
    const promise = service.create(reporterId, baseDto);

    await expect(promise).rejects.toThrow(ConflictException);
    await expect(promise).rejects.toThrow('Este servicio ya fue reportado');
  });

  it('devuelve Conflict cuando el índice único falla con 23505', async () => {
    const driverError = Object.assign(new Error('duplicate key'), {
      code: '23505',
      constraint: 'uq_reports_service_request_id',
    });
    reportRepository.save.mockRejectedValueOnce(
      new QueryFailedError('INSERT INTO reports', [], driverError),
    );

    await expect(service.create(reporterId, baseDto)).rejects.toThrow(
      ConflictException,
    );
  });

  it('no mapea un 23505 de otra constraint', async () => {
    const driverError = Object.assign(new Error('duplicate key'), {
      code: '23505',
      constraint: 'some_other_constraint',
    });
    const error = new QueryFailedError('INSERT INTO reports', [], driverError);
    reportRepository.save.mockRejectedValueOnce(error);

    await expect(service.create(reporterId, baseDto)).rejects.toBe(error);
  });

  it('permite reportes sin serviceRequestId', async () => {
    profileColabRepository.findOne.mockResolvedValueOnce({
      userId: 'colab-2',
    } as ProfileColab);
    const dto: CreateReportDto = {
      profileColabId: 'pc-2',
      category: 'comportamiento_inapropiado',
    };

    const result = await service.create(reporterId, dto);

    expect(serviceRequestRepository.findOne).not.toHaveBeenCalled();
    expect(reportRepository.findOne).not.toHaveBeenCalled();
    expect(reportRepository.save).toHaveBeenCalled();
    expect(result).toEqual(
      expect.objectContaining({ reportedUserId: 'colab-2' }),
    );
  });

  it('rechaza un servicio que no pertenece al reportante', async () => {
    serviceRequestRepository.findOne.mockResolvedValueOnce({
      ...validServiceRequest(),
      userId: 'another-user',
    });

    await expect(service.create(reporterId, baseDto)).rejects.toThrow(
      ForbiddenException,
    );
  });

  it('rechaza un servicio que no está cancelado', async () => {
    serviceRequestRepository.findOne.mockResolvedValueOnce({
      ...validServiceRequest(),
      status: ServiceRequestStatus.PENDING,
    });

    await expect(service.create(reporterId, baseDto)).rejects.toThrow(
      BadRequestException,
    );
  });

  it('rechaza un servicio sin colaborador ganador', async () => {
    serviceRequestRepository.findOne.mockResolvedValueOnce({
      ...validServiceRequest(),
      proposals: [],
    });

    await expect(service.create(reporterId, baseDto)).rejects.toThrow(
      'El servicio no tiene colaborador ganador',
    );
  });

  it('rechaza el auto-reporte', async () => {
    serviceRequestRepository.findOne.mockResolvedValueOnce({
      ...validServiceRequest(),
      proposals: [
        {
          status: ProposalStatus.ACCEPTED,
          profileColabId: 'pc-1',
          profileColab: { userId: reporterId },
        },
      ],
    } as ServiceRequest);

    await expect(service.create(reporterId, baseDto)).rejects.toThrow(
      'No puedes reportarte a ti mismo',
    );
  });
});
