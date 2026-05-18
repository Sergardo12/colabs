import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { SuggestionService } from './suggestion.service';
import { CreateSuggestionDto } from './dto/create-suggestion.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('suggestions')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('suggestions')
export class SuggestionController {
  constructor(private suggestionService: SuggestionService) {}

  @Post()
  @ApiOperation({ summary: 'Enviar sugerencia a Colabs' })
  create(@Request() req: any, @Body() dto: CreateSuggestionDto) {
    return this.suggestionService.create(req.user.id, dto);
  }

  @Get('my-suggestions')
  @ApiOperation({ summary: 'Mis sugerencias enviadas' })
  findMySuggestions(@Request() req: any) {
    return this.suggestionService.findMySuggestions(req.user.id);
  }
}