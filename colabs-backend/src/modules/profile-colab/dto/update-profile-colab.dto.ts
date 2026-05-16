import { PartialType } from '@nestjs/swagger';
import { CreateProfileColabDto } from './create-profile-colab.dto';

export class UpdateProfileColabDto extends PartialType(CreateProfileColabDto) {}