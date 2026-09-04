import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { FavoriteController } from './favorite.controller';
import { FavoriteService } from './favorite.service';
import { UserFavorite } from './entities/user-favorite.entity';
import { ProfileColab } from '../profile-colab/entities/profile-colab.entity';

@Module({
  imports: [TypeOrmModule.forFeature([UserFavorite, ProfileColab])],
  controllers: [FavoriteController],
  providers: [FavoriteService],
  exports: [FavoriteService],
})
export class FavoriteModule {}
