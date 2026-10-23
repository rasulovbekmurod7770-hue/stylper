// JSON over POST for the Edge Functions. The web app calls them cross-origin
// (Chrome on http://localhost:5000 in development), so every response, errors
// included, carries the CORS headers, and preflights are answered before any
// auth check.

export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

/** An error the app can act on: `{ error: code, message }` with a status.
 * Codes are the app's `ApiErrorCodes`. */
export class ApiError extends Error {
  constructor(
    readonly status: number,
    readonly code: string,
    message: string,
  ) {
    super(message);
  }
}

export type JsonBody = Record<string, unknown>;

export function json(status: number, body: unknown): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

/** Serves [handler] for `POST` with a JSON object body; its result is the
 * 200 response. */
export function serveJson(
  handler: (req: Request, body: JsonBody) => Promise<unknown>,
): void {
  Deno.serve(async (req) => {
    if (req.method === "OPTIONS") {
      return new Response("ok", { headers: corsHeaders });
    }
    try {
      if (req.method !== "POST") {
        throw new ApiError(405, "method_not_allowed", "Use POST.");
      }
      const body = await req.json().catch(() => null);
      if (typeof body !== "object" || body === null || Array.isArray(body)) {
        throw new ApiError(400, "validation_failed", "Send a JSON object.");
      }
      return json(200, await handler(req, body as JsonBody));
    } catch (error) {
      if (error instanceof ApiError) {
        return json(error.status, { error: error.code, message: error.message });
      }
      console.error(error);
      return json(500, { error: "server_error", message: "Try again later." });
    }
  });
}

const uuidPattern =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export function isUuid(value: unknown): value is string {
  return typeof value === "string" && uuidPattern.test(value);
}

export function isPositiveInt(value: unknown, max: number): value is number {
  return Number.isInteger(value) && (value as number) > 0 &&
    (value as number) <= max;
}
