import { registerAs } from '@nestjs/config';

export default registerAs('storage', () => ({
  keyId: process.env.B2_KEY_ID,
  applicationKey: process.env.B2_APPLICATION_KEY,
  endpoint: process.env.B2_ENDPOINT,
  region: process.env.B2_REGION,
  publicBucket: process.env.B2_PUBLIC_BUCKET,
  privateBucket: process.env.B2_PRIVATE_BUCKET,
  publicBaseUrl: process.env.B2_PUBLIC_BASE_URL,
}));