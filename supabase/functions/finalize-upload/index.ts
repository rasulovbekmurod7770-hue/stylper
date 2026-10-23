// POST /functions/v1/finalize-upload (the uploader)
//   { media_id }
//   → { media_id, full_url, thumb_url, width, height, blurhash }
//
// Step 2 of an upload (STYLPER_BACKEND_SPEC.md §6): checks that both files
// are in R2, are WebP and are at most 2 MB, then marks the `media` row ready.
// Only ready media can be attached to posts, avatars or products (RLS).
//
// Errors: `upload_incomplete` (a file isn't there yet; the row stays pending,
// so the app may PUT again while the URLs last), `upload_rejected` (a file
// isn't a WebP of the right size; both are deleted and the row is rejected).
// Finalizing a ready row again returns the same answer, so a retry after a
// lost response works.
import { ApiError, isUuid, serveJson } from "../_shared/http.ts";
import {
  inspect,
  maxUploadBytes,
  publicUrl,
  remove,
  type StoredObject,
  webp,
} from "../_shared/r2.ts";
import { admin, requireUser } from "../_shared/supabase.ts";

type Media = {
  id: string;
  owner_id: string | null;
  status: "pending" | "ready" | "rejected";
  full_key: string;
  thumb_key: string;
  width: number | null;
  height: number | null;
  blurhash: string | null;
};

serveJson(async (req, body) => {
  const userId = await requireUser(req);
  const mediaId = body.media_id;
  if (!isUuid(mediaId)) {
    throw new ApiError(400, "validation_failed", "media_id must be a uuid.");
  }

  const { data, error } = await admin
    .from("media")
    .select("id, owner_id, status, full_key, thumb_key, width, height, blurhash")
    .eq("id", mediaId)
    .maybeSingle();
  if (error) throw error;
  const media = data as Media | null;
  // Someone else's upload looks the same as none.
  if (!media || media.owner_id !== userId) {
    throw new ApiError(404, "not_found", "No such upload.");
  }
  if (media.status === "ready") return result(media);
  if (media.status !== "pending") {
    throw new ApiError(409, "upload_rejected", "This upload was rejected.");
  }

  const [full, thumb] = await Promise.all([
    inspect(media.full_key),
    inspect(media.thumb_key),
  ]);
  if (!full || !thumb) {
    throw new ApiError(409, "upload_incomplete", "Upload both files first.");
  }
  if (!acceptable(full) || !acceptable(thumb)) {
    await Promise.all([remove(media.full_key), remove(media.thumb_key)]);
    await admin.from("media").update({ status: "rejected" }).eq("id", media.id)
      .eq("status", "pending");
    throw new ApiError(
      422,
      "upload_rejected",
      "Upload WebP images of at most 2 MB.",
    );
  }

  // `bytes` becomes what R2 holds rather than what the app announced.
  const { error: updateError } = await admin
    .from("media")
    .update({ status: "ready", bytes: full.size })
    .eq("id", media.id)
    .eq("status", "pending");
  if (updateError) throw updateError;
  return result(media);
});

function acceptable(file: StoredObject): boolean {
  return file.isWebp && file.contentType === webp && file.size > 0 &&
    file.size <= maxUploadBytes;
}

function result(media: Media) {
  return {
    media_id: media.id,
    full_url: publicUrl(media.full_key),
    thumb_url: publicUrl(media.thumb_key),
    width: media.width,
    height: media.height,
    blurhash: media.blurhash,
  };
}
