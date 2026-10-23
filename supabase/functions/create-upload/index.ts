// POST /functions/v1/create-upload (signed-in users)
//   { kind: 'post'|'avatar'|'wardrobe'|'product'|'brand', brand_id?, width,
//     height, bytes, blurhash }
//   → { media_id, full_put_url, thumb_put_url, expires_in }
//
// Step 1 of an upload (STYLPER_BACKEND_SPEC.md §6): inserts a pending `media`
// row and returns presigned R2 PUT URLs for its two WebP files, full (longest
// side 1080) and thumb (400). The app PUTs both with `Content-Type:
// image/webp`, then calls finalize-upload.
import {
  ApiError,
  isPositiveInt,
  isUuid,
  type JsonBody,
  serveJson,
} from "../_shared/http.ts";
import { maxUploadBytes, presignPut } from "../_shared/r2.ts";
import { admin, requireUser } from "../_shared/supabase.ts";

const kinds = ["post", "avatar", "wardrobe", "product", "brand"];

/** Kinds that belong to a brand: the uploader must be on its team. */
const brandKinds = ["product", "brand"];

/** Pending (not yet finalized) uploads a user may start per hour. */
const maxPendingPerHour = 30;

const putUrlSeconds = 10 * 60;

/** Sanity bound only; the app sends at most 1080. */
const maxSide = 4096;

const blurhashPattern = /^[0-9A-Za-z#$%*+,\-.:;=?@[\]^_{|}~]{6,200}$/;

serveJson(async (req, body) => {
  const userId = await requireUser(req);
  const upload = parse(body);

  if (upload.brandId) {
    const { data, error } = await admin
      .from("brand_members")
      .select("user_id")
      .eq("brand_id", upload.brandId)
      .eq("user_id", userId)
      .maybeSingle();
    if (error) throw error;
    if (!data) {
      throw new ApiError(403, "forbidden", "You're not on this brand's team.");
    }
  }

  const hourAgo = new Date(Date.now() - 60 * 60 * 1000).toISOString();
  const { count, error: countError } = await admin
    .from("media")
    .select("id", { count: "exact", head: true })
    .eq("owner_id", userId)
    .eq("status", "pending")
    .gte("created_at", hourAgo);
  if (countError) throw countError;
  if ((count ?? 0) >= maxPendingPerHour) {
    throw new ApiError(
      429,
      "too_many_requests",
      "Too many uploads in the last hour. Try again later.",
    );
  }

  // Keys never change (each upload gets a new id), so they can be cached
  // for a year: {kind}/{user_or_brand_id}/{uuid}_1080.webp and _400.webp.
  const id = crypto.randomUUID();
  const folder = `${upload.kind}/${upload.brandId ?? userId}/${id}`;
  const fullKey = `${folder}_1080.webp`;
  const thumbKey = `${folder}_400.webp`;

  const { error: insertError } = await admin.from("media").insert({
    id,
    owner_id: userId,
    brand_id: upload.brandId,
    kind: upload.kind,
    full_key: fullKey,
    thumb_key: thumbKey,
    width: upload.width,
    height: upload.height,
    bytes: upload.bytes,
    blurhash: upload.blurhash,
    status: "pending",
  });
  if (insertError) throw insertError;

  const [fullPutUrl, thumbPutUrl] = await Promise.all([
    presignPut(fullKey, putUrlSeconds),
    presignPut(thumbKey, putUrlSeconds),
  ]);
  return {
    media_id: id,
    full_put_url: fullPutUrl,
    thumb_put_url: thumbPutUrl,
    expires_in: putUrlSeconds,
  };
});

function parse(body: JsonBody) {
  const invalid = (message: string) =>
    new ApiError(400, "validation_failed", message);
  const { kind, brand_id: brandId, width, height, bytes, blurhash } = body;

  if (typeof kind !== "string" || !kinds.includes(kind)) {
    throw invalid(`kind must be one of ${kinds.join(", ")}.`);
  }
  const forBrand = brandKinds.includes(kind);
  if (forBrand && !isUuid(brandId)) {
    throw invalid(`A ${kind} photo needs the brand_id of its brand.`);
  }
  if (!forBrand && brandId != null) {
    throw invalid(`brand_id is only for ${brandKinds.join(" and ")} photos.`);
  }
  if (!isPositiveInt(width, maxSide) || !isPositiveInt(height, maxSide)) {
    throw invalid("width and height must be whole pixels.");
  }
  if (!Number.isInteger(bytes) || (bytes as number) <= 0) {
    throw invalid("bytes must be the full image's size.");
  }
  if ((bytes as number) > maxUploadBytes) {
    throw new ApiError(413, "file_too_large", "The photo is over 2 MB.");
  }
  if (blurhash != null && !(typeof blurhash === "string" &&
    blurhashPattern.test(blurhash))) {
    throw invalid("blurhash isn't a blurhash.");
  }
  return {
    kind,
    brandId: forBrand ? brandId as string : null,
    width: width as number,
    height: height as number,
    bytes: bytes as number,
    blurhash: (blurhash as string | undefined) ?? null,
  };
}
