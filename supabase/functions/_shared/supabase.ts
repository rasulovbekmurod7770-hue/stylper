import {
  createClient,
  type SupabaseClient,
} from "npm:@supabase/supabase-js@2.117.3";

import { ApiError } from "./http.ts";

/** Service-role client: bypasses RLS, so it writes what clients may not
 * (`media`). Supabase injects the project's URL and secret key into every
 * function, locally and in the cloud. */
export const admin: SupabaseClient = createClient(
  Deno.env.get("SUPABASE_URL")!,
  secretKey(),
  { auth: { persistSession: false, autoRefreshToken: false } },
);

function secretKey(): string {
  // `SUPABASE_SECRET_KEYS` is a JSON object of the project's secret keys;
  // stacks from before the new API keys only have the legacy service role.
  const keys = Deno.env.get("SUPABASE_SECRET_KEYS");
  if (keys) {
    const parsed = JSON.parse(keys) as Record<string, string>;
    const key = parsed.default ?? Object.values(parsed)[0];
    if (key) return key;
  }
  const legacy = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (legacy) return legacy;
  throw new Error("No Supabase secret key in the function's environment");
}

/** The signed-in caller's user id, from `Authorization: Bearer <access
 * token>`. The functions check it themselves (`verify_jwt = false` in
 * config.toml), which works with both legacy and asymmetric JWT keys. */
export async function requireUser(req: Request): Promise<string> {
  const token = req.headers.get("Authorization")?.replace(/^Bearer\s+/i, "");
  if (token) {
    const { data, error } = await admin.auth.getUser(token);
    if (!error && data.user) return data.user.id;
  }
  throw new ApiError(401, "unauthorized", "Sign in first.");
}
