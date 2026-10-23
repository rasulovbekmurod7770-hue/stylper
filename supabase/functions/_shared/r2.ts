// Cloudflare R2 through its S3 API: presigned PUTs for the app, signed reads
// and deletes for the functions. Secrets: R2_ACCOUNT_ID, R2_ACCESS_KEY_ID,
// R2_SECRET_ACCESS_KEY, R2_BUCKET, and IMG_PUBLIC_BASE, where the bucket's
// objects are public (`supabase/functions/.env.example`).
import { AwsClient } from "npm:aws4fetch@1.0.20";

export const webp = "image/webp";

/** Largest file the app may upload (each of the two). */
export const maxUploadBytes = 2 * 1024 * 1024;

/** A request to R2 that takes longer fails, rather than hanging the
 * function (and the app's spinner) until the runtime gives up. */
const requestMs = 10_000;

type R2 = { client: AwsClient; bucketUrl: string; publicBase: string };
let r2: R2 | undefined;

/** Read on first use, so a missing secret fails the request (logged by
 * name) rather than the function's boot. */
function config(): R2 {
  if (r2) return r2;
  const env = (name: string) => {
    const value = Deno.env.get(name)?.trim();
    if (!value) throw new Error(`Edge Function secret ${name} is not set`);
    return value;
  };
  r2 = {
    client: new AwsClient({
      accessKeyId: env("R2_ACCESS_KEY_ID"),
      secretAccessKey: env("R2_SECRET_ACCESS_KEY"),
      service: "s3",
      region: "auto",
      retries: 2, // after a 5xx or 429; 10 by default
    }),
    bucketUrl: `https://${env("R2_ACCOUNT_ID")}.r2.cloudflarestorage.com/${
      env("R2_BUCKET")
    }`,
    publicBase: env("IMG_PUBLIC_BASE").replace(/\/+$/, ""),
  };
  return r2;
}

export function publicUrl(key: string): string {
  return `${config().publicBase}/${key}`;
}

/** A presigned PUT URL for [key], valid for [expiresIn] seconds. The
 * Content-Type is signed too, so the upload must send `image/webp`. */
export async function presignPut(key: string, expiresIn: number) {
  const { client, bucketUrl } = config();
  const url = new URL(`${bucketUrl}/${key}`);
  url.searchParams.set("X-Amz-Expires", String(expiresIn));
  const signed = await client.sign(url, {
    method: "PUT",
    headers: { "Content-Type": webp },
    aws: { signQuery: true, allHeaders: true },
  });
  return signed.url;
}

export type StoredObject = {
  size: number;
  contentType: string | null;
  /** The file starts with the WebP signature (`RIFF····WEBP`). */
  isWebp: boolean;
};

/** What R2 holds at [key], or null if nothing. Reads only the first 12
 * bytes: like a HEAD (size, content type), plus the file signature, so a
 * file that merely claims to be WebP doesn't pass. */
export async function inspect(key: string): Promise<StoredObject | null> {
  const { client, bucketUrl } = config();
  const res = await client.fetch(`${bucketUrl}/${key}`, {
    headers: { Range: "bytes=0-11" },
    signal: AbortSignal.timeout(requestMs),
  });
  if (res.status === 404) {
    await res.body?.cancel();
    return null;
  }
  if (res.status === 416) {
    // An empty file: no first byte to read.
    await res.body?.cancel();
    return { size: 0, contentType: res.headers.get("content-type"), isWebp: false };
  }
  if (!res.ok) throw new Error(`R2 read of ${key} failed: ${res.status}`);
  const head = new Uint8Array(await res.arrayBuffer());
  const total = res.headers.get("content-range")?.split("/")[1];
  const ascii = (from: number, to: number) =>
    String.fromCharCode(...head.subarray(from, to));
  return {
    size: Number(total ?? res.headers.get("content-length")),
    contentType: res.headers.get("content-type"),
    isWebp: head.length === 12 && ascii(0, 4) === "RIFF" &&
      ascii(8, 12) === "WEBP",
  };
}

export async function remove(key: string): Promise<void> {
  const { client, bucketUrl } = config();
  const res = await client.fetch(`${bucketUrl}/${key}`, {
    method: "DELETE",
    signal: AbortSignal.timeout(requestMs),
  });
  await res.body?.cancel();
  if (!res.ok && res.status !== 404) {
    throw new Error(`R2 delete of ${key} failed: ${res.status}`);
  }
}
