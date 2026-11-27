import { ProposalStatus } from '../../common/enums/proposal-status.enum';
import { ServiceRequestStatus } from '../../common/enums/service-request-status.enum';
import { CommentRequestService } from './comment-request.service';

class QueryBuilderMock {
  innerJoinAndSelect = jest.fn().mockReturnThis();
  where = jest.fn().mockReturnThis();
  andWhere = jest.fn().mockReturnThis();
  setParameters = jest.fn().mockReturnThis();
  orderBy = jest.fn().mockReturnThis();
  getMany = jest.fn();
}

describe('CommentRequestService.findByProfileColab', () => {
  const profileColabId = 'profile-1';

  const buildService = (comments: unknown[] = []) => {
    const query = new QueryBuilderMock();
    query.getMany.mockResolvedValue(comments);

    const commentRequestRepository = {
      createQueryBuilder: jest.fn(() => query),
    };
    const serviceRequestRepository = {};
    const service = new CommentRequestService(
      commentRequestRepository as never,
      serviceRequestRepository as never,
    );

    return { service, query };
  };

  const winnerSql = (query: QueryBuilderMock) =>
    query.andWhere.mock.calls.map(([sql]) => sql).join(' ');

  it('excluye reseñas de otro colaborador que solo comparte ocupación', async () => {
    const { service, query } = buildService();

    await service.findByProfileColab(profileColabId);

    const sql = winnerSql(query);
    expect(sql).not.toContain('profile_colab_occupations');
    expect(sql).toContain('sr.profile_colab_id = :profileColabId');
    expect(sql).toContain(
      'acceptedProposal.profile_colab_id = :profileColabId',
    );
    expect(query.setParameters).toHaveBeenCalledWith({
      profileColabId,
      acceptedStatus: ProposalStatus.ACCEPTED,
    });
  });

  it('excluye reseñas inactivas y servicios no completados', async () => {
    const { service, query } = buildService();

    await service.findByProfileColab(profileColabId);

    expect(query.where).toHaveBeenCalledWith('cr.status = :active', {
      active: 'active',
    });
    expect(query.andWhere).toHaveBeenCalledWith('sr.status = :completed', {
      completed: ServiceRequestStatus.COMPLETED,
    });
  });

  it('incluye reseñas de servicios completados sin completion_date', async () => {
    const comments = [
      { id: 'c1', rating: 5, serviceRequest: { completionDate: null } },
    ];
    const { service, query } = buildService(comments);

    const result = await service.findByProfileColab(profileColabId);

    expect(winnerSql(query)).not.toContain('completion_date');
    expect(result).toMatchObject({ averageRating: 5, totalReviews: 1 });
    expect(result.comments).toBe(comments);
  });

  it('incluye Flujo B por conversación cuando no hay proposal aceptada', async () => {
    const comments = [{ id: 'c1', rating: 4 }];
    const { service, query } = buildService(comments);

    const result = await service.findByProfileColab(profileColabId);

    const sql = winnerSql(query);
    expect(sql).toContain('NOT EXISTS');
    expect(sql).toContain('flowBConversation.post_id IS NOT NULL');
    expect(sql).toContain(
      'flowBConversation.profile_colab_id = :profileColabId',
    );
    expect(result).toMatchObject({ averageRating: 4, totalReviews: 1 });
  });

  it('no usa la conversación cuando hay proposal aceptada de otro colaborador', async () => {
    const { service, query } = buildService();

    await service.findByProfileColab(profileColabId);

    const sql = winnerSql(query);
    const acceptedProposalGuard = sql.indexOf('anyAcceptedProposal');
    const conversationFallback = sql.indexOf('flowBConversation');
    expect(acceptedProposalGuard).toBeGreaterThan(-1);
    expect(conversationFallback).toBeGreaterThan(acceptedProposalGuard);
    expect(sql).toContain('NOT EXISTS');
    expect(sql).toContain('acceptedProposal.status = :acceptedStatus');
  });

  it('no duplica reseñas con joins a propuestas o conversaciones', async () => {
    const { service, query } = buildService([{ id: 'c1', rating: 4 }]);

    const result = await service.findByProfileColab(profileColabId);

    const joins = query.innerJoinAndSelect.mock.calls.map(([relation]) =>
      String(relation),
    );
    expect(joins).toEqual(['cr.serviceRequest', 'sr.occupation', 'cr.user']);
    expect(winnerSql(query)).toContain('EXISTS');
    expect(result.totalReviews).toBe(1);
  });

  it('calcula promedio con un decimal y totalReviews', async () => {
    const comments = [
      { id: 'c1', rating: 5 },
      { id: 'c2', rating: 5 },
      { id: 'c3', rating: 4 },
    ];
    const { service } = buildService(comments);

    await expect(service.findByProfileColab(profileColabId)).resolves.toEqual({
      averageRating: 4.7,
      totalReviews: 3,
      comments,
    });
  });

  it('devuelve promedio 0 y totalReviews 0 sin reseñas', async () => {
    const { service } = buildService();

    await expect(service.findByProfileColab(profileColabId)).resolves.toEqual({
      averageRating: 0,
      totalReviews: 0,
      comments: [],
    });
  });
});
