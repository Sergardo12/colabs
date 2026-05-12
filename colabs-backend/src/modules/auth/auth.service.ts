import { Injectable, ConflictException, UnauthorizedException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { User } from '../users/entities/user.entity';
import { UserProvider } from '../users/entities/user-provider.entity';
import { RegisterDto } from './dto/register.dto';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,

    @InjectRepository(UserProvider)
    private userProviderRepository: Repository<UserProvider>,

    private jwtService: JwtService,
  ) {}

  async register(registerDto: RegisterDto) {
    // Verificar si el email ya existe
    const existingUser = await this.userRepository.findOne({
      where: { email: registerDto.email },
    });

    if (existingUser) {
      throw new ConflictException('El email ya está registrado');
    }

    // Crear el usuario
    const user = this.userRepository.create({
      email: registerDto.email,
      name: registerDto.name,
      lastName: registerDto.lastName,
      phoneNumber: registerDto.phoneNumber,
    });

    const savedUser = await this.userRepository.save(user);

    // Crear el provider local con el hash de la contraseña
    const passwordHash = await bcrypt.hash(registerDto.password, 10);

    const provider = this.userProviderRepository.create({
      userId: savedUser.id,
      provider: 'local',
      passwordHash,
    });

    await this.userProviderRepository.save(provider);

    // Emitir JWT
    return this.generateToken(savedUser);
  }

  async validateUser(email: string, password: string) {
    // Buscar usuario por email
    const user = await this.userRepository.findOne({
      where: { email },
    });

    if (!user) return null;

    // Buscar su provider local con el password_hash
    const provider = await this.userProviderRepository
      .createQueryBuilder('provider')
      .addSelect('provider.passwordHash')
      .where('provider.userId = :userId', { userId: user.id })
      .andWhere('provider.provider = :provider', { provider: 'local' })
      .getOne();

    if (!provider) return null;

    // Comparar contraseña
    const isValid = await bcrypt.compare(password, provider.passwordHash);
    if (!isValid) return null;

    return user;
  }


  async login(user: User) {
    return this.generateToken(user);
  }

  async getMe(userId: string) {
    return this.userRepository.findOne({
      where: { id: userId },
    });
  }

  private generateToken(user: User) {
    const payload = {
      sub: user.id,
      email: user.email,
    };

    return {
      access_token: this.jwtService.sign(payload),
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        lastName: user.lastName,
      },
    };
  }

  async validateOAuthUser(oauthData: {
  email: string;
  name: string;
  lastName: string;
  imageProfile?: string;
  provider: string;
  providerId: string;
}) {
  // Buscar si ya existe el provider
  let provider = await this.userProviderRepository.findOne({
    where: {
      provider: oauthData.provider,
      providerId: oauthData.providerId,
    },
  });

  if (provider) {
    // Ya existe — busca el usuario y devuelve token
    const user = await this.userRepository.findOne({
      where: { id: provider.userId },
    });
    return this.generateToken(user!);
  }

  // Buscar si el email ya existe con otro provider
  let user = await this.userRepository.findOne({
    where: { email: oauthData.email },
  });

  if (!user) {
    // Usuario nuevo — crear
    user = this.userRepository.create({
      email: oauthData.email,
      name: oauthData.name,
      lastName: oauthData.lastName,
      imageProfile: oauthData.imageProfile,
    });
    user = await this.userRepository.save(user);
  }

  // Crear el provider OAuth
  const newProvider = this.userProviderRepository.create({
    userId: user.id,
    provider: oauthData.provider,
    providerId: oauthData.providerId,
  });
  await this.userProviderRepository.save(newProvider);

  return this.generateToken(user);
}


}