import { Injectable,   BadRequestException, ServiceUnavailableException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GetObjectCommand, PutObjectCommand, S3Client, HeadObjectCommand } from '@aws-sdk/client-s3';
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

    /**
   * Verifica que cada URL sea una imagen PÚBLICA subida por este usuario
   * y que exista realmente en B2. Lanza excepción si algo no cuadra.
   * Reutilizable para posts, avatares, y en el futuro videos.
   */
  async assertOwnedPublicUploads(
    userId: string,
    kind: UploadKind,
    urls: string[],
  ): Promise<void> {
    if (kind === UploadKind.DNI) {
      throw new BadRequestException('Este tipo de archivo no es público');
    }

    const prefix = `${this.publicBaseUrl}/${kind}/${userId}/`;
    const fileNameRegex = new RegExp(
      `^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\\.(${Object.values(EXT).join('|')})$`,
      'i',
    );

    const keys = urls.map((url) => {
      if (!url.startsWith(prefix)) {
        throw new BadRequestException('Una de las imágenes no es válida');
      }
      const fileName = url.slice(prefix.length);
      if (!fileNameRegex.test(fileName)) {
        throw new BadRequestException('Una de las imágenes no es válida');
      }
      return `${kind}/${userId}/${fileName}`;
    });

    await Promise.all(keys.map((key) => this.assertObjectExists(key)));
  }

  private async assertObjectExists(key: string): Promise<void> {
    try {
      await this.s3.send(
        new HeadObjectCommand({ Bucket: this.publicBucket, Key: key }),
      );
    } catch (err: any) {
      if (err?.name === 'NotFound' || err?.$metadata?.httpStatusCode === 404) {
        throw new BadRequestException(
          'Una de las imágenes no se encontró, vuelve a subirla',
        );
      }
      // Cualquier otro error (red, permisos, B2 caído) no es culpa del usuario
      throw new ServiceUnavailableException(
        'No se pudo verificar la imagen, intenta de nuevo',
      );
    }
  }
}