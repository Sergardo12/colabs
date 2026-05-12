import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { OccupationService } from './occupation.service';
import { CreateOccupationDto } from './dto/create-occupation.dto';
import { UpdateOccupationDto } from './dto/update-occupation.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('occupations')
@Controller('occupations')
export class OccupationController {
  constructor(private occupationService: OccupationService) {}

  @Get()
  @ApiOperation({ summary: 'Listar todos los oficios activos' })
  findAll() {
    return this.occupationService.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener un oficio por id' })
  findOne(@Param('id') id: string) {
    return this.occupationService.findOne(id);
  }

  @Post()
  @ApiOperation({ summary: 'Crear un oficio (solo admin)' })
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  create(@Body() createOccupationDto: CreateOccupationDto) {
    return this.occupationService.create(createOccupationDto);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Actualizar un oficio (solo admin)' })
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  update(
    @Param('id') id: string,
    @Body() updateOccupationDto: UpdateOccupationDto,
  ) {
    return this.occupationService.update(id, updateOccupationDto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Desactivar un oficio (solo admin)' })
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  remove(@Param('id') id: string) {
    return this.occupationService.remove(id);
  }
}