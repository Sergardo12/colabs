import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  GetObjectCommand,
  PutObjectCommand,
  S3Client,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { randomUUID } from 'crypto';
import { PresignUploadDto, UploadKind } from './dto/presign-upload.dto';

const EXT: Record<string, string> = {
  'image/jpeg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
};

@Injectable()
export class StorageService {
  private readonly s3: S3Client;
  private readonly publicBucket: string;
  private readonly privateBucket: string;
  private readonly publicBaseUrl: string;

  constructor(private config: ConfigService) {
    this.publicBucket = this.config.getOrThrow<string>('storage.publicBucket');
    this.privateBucket = this.config.getOrThrow<string>('storage.privateBucket');
    this.publicBaseUrl = this.config.getOrThrow<string>('storage.publicBaseUrl');

    this.s3 = new S3Client({
      region: this.config.getOrThrow<string>('storage.region'),
      endpoint: this.config.getOrThrow<string>('storage.endpoint'),
      credentials: {
        accessKeyId: this.config.getOrThrow<string>('storage.keyId'),
        secretAccessKey: this.config.getOrThrow<string>('storage.applicationKey'),
      },
    });
  }

  async presignUpload(userId: string, dto: PresignUploadDto) {
    const isPrivate = dto.kind === UploadKind.DNI;
    const bucket = isPrivate ? this.privateBucket : this.publicBucket;
    // La carpeta incluye el userId: facilita auditar y borrar por usuario
    const key = `${dto.kind}/${userId}/${randomUUID()}.${EXT[dto.contentType]}`;

    const command = new PutObjectCommand({
      Bucket: bucket,
      Key: key,
      ContentType: dto.contentType,
      ContentLength: dto.size,
    });

    const uploadUrl = await getSignedUrl(this.s3, command, { expiresIn: 300 });

    return {
      uploadUrl,
      key,
      // Público: URL final directa. Privado: se pide aparte con presignRead.
      publicUrl: isPrivate ? null : `${this.publicBaseUrl}/${key}`,
    };
  }

  async presignRead(key: string) {
    const command = new GetObjectCommand({
      Bucket: this.privateBucket,
      Key: key,
    });
    return getSignedUrl(this.s3, command, { expiresIn: 300 });
  }
}