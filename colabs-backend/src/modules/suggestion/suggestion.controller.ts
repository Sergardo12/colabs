import { Controller, Get, Post, Body, UseGuards} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { SuggestionService } from './suggestion.service';
import { CreateSuggestionDto } from './dto/create-suggestion.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from 'src/common/decorators/current-user.decorator';
import type { JwtPayload } from 'src/common/interfaces/jwt-payload.interface';

@ApiTags('suggestions')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('suggestions')
export class SuggestionController {
  constructor(private suggestionService: SuggestionService) {}

  @Post()
  @ApiOperation({ summary: 'Enviar sugerencia a Colabs' })
  create(@CurrentUser() user: JwtPayload, @Body() dto: CreateSuggestionDto) {
    return this.suggestionService.create(user.id, dto);
  }

  @Get('my-suggestions')
  @ApiOperation({ summary: 'Mis sugerencias enviadas' })
  findMySuggestions(@CurrentUser() user: JwtPayload) {
    return this.suggestionService.findMySuggestions(user.id);
  }
}