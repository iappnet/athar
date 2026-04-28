/**
 * supabase/functions/revenuecat-webhook/index.ts
 *
 * Receives RevenueCat server-to-server webhook events and keeps the
 * user_entitlements table in sync.
 *
 * Setup (Supabase Dashboard → Edge Functions → Secrets):
 *   REVENUECAT_WEBHOOK_SECRET  — from RevenueCat Dashboard → Integrations →
 *                                Webhooks → your endpoint → "Authorization header"
 *
 * RevenueCat webhook config:
 *   URL:     https://<project>.supabase.co/functions/v1/revenuecat-webhook
 *   Header:  Authorization: <REVENUECAT_WEBHOOK_SECRET>
 *
 * Events handled:
 *   INITIAL_PURCHASE, RENEWAL, PRODUCT_CHANGE,
 *   EXPIRATION, CANCELLATION, BILLING_ISSUE,
 *   SUBSCRIBER_ALIAS (ignored — no entitlement change)
 */

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// ── Types ──────────────────────────────────────────────────────────────────

interface RevenueCatEvent {
  type: string;
  app_user_id: string;          // This is the Supabase user UUID (see note below)
  product_id: string;
  entitlement_ids: string[];    // e.g. ["spaces_pro"]
  expiration_at_ms: number | null;
  environment: "SANDBOX" | "PRODUCTION";
}

interface RevenueCatPayload {
  event: RevenueCatEvent;
}

// Events that mean the entitlement is currently ACTIVE
const ACTIVE_EVENTS = new Set([
  "INITIAL_PURCHASE",
  "RENEWAL",
  "PRODUCT_CHANGE",
  "UNCANCELLATION",
  "TRANSFER",
]);

// Events that mean the entitlement is NO LONGER active
const INACTIVE_EVENTS = new Set([
  "EXPIRATION",
  "CANCELLATION",
  "BILLING_ISSUE",
  "SUBSCRIPTION_PAUSED",
]);

// ── Handler ────────────────────────────────────────────────────────────────

serve(async (req: Request) => {
  // ── 1. Verify the Authorization header ──────────────────────────────────
  const expectedSecret = Deno.env.get("REVENUECAT_WEBHOOK_SECRET");
  if (!expectedSecret) {
    console.error("REVENUECAT_WEBHOOK_SECRET not configured");
    return new Response("Server misconfiguration", { status: 500 });
  }

  const authHeader = req.headers.get("Authorization") ?? "";
  if (authHeader !== expectedSecret) {
    console.warn("Webhook: invalid Authorization header");
    return new Response("Unauthorized", { status: 401 });
  }

  // ── 2. Parse body ────────────────────────────────────────────────────────
  let payload: RevenueCatPayload;
  try {
    payload = await req.json();
  } catch {
    return new Response("Bad JSON", { status: 400 });
  }

  const event = payload?.event;
  if (!event?.type || !event?.app_user_id) {
    return new Response("Missing event fields", { status: 400 });
  }

  console.log(`RevenueCat event: ${event.type} | user: ${event.app_user_id} | env: ${event.environment}`);

  // ── 3. Determine active/inactive ─────────────────────────────────────────
  const isActive   = ACTIVE_EVENTS.has(event.type);
  const isInactive = INACTIVE_EVENTS.has(event.type);

  if (!isActive && !isInactive) {
    // SUBSCRIBER_ALIAS, TEST, etc. — nothing to do
    console.log(`Ignoring event type: ${event.type}`);
    return new Response("OK", { status: 200 });
  }

  const entitlementIds: string[] = event.entitlement_ids ?? [];
  if (entitlementIds.length === 0) {
    console.log("No entitlement_ids in event — skipping");
    return new Response("OK", { status: 200 });
  }

  // ── 4. Build the Supabase service-role client ────────────────────────────
  // Uses service_role so it can bypass RLS and write to user_entitlements.
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false } }
  );

  // ── 5. Resolve the Supabase user UUID ───────────────────────────────────
  // IMPORTANT: In RevenueCat, set the App User ID to the Supabase user UUID
  // by calling Purchases.logIn(supabaseUserId) after the user authenticates.
  // app_user_id will then be the UUID directly.
  const userId = event.app_user_id;

  // Basic UUID format sanity check
  const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  if (!UUID_RE.test(userId)) {
    console.error(`app_user_id is not a UUID: ${userId}`);
    return new Response("Invalid app_user_id format", { status: 400 });
  }

  // ── 6. Upsert each entitlement ───────────────────────────────────────────
  const expiresAt = event.expiration_at_ms
    ? new Date(event.expiration_at_ms).toISOString()
    : null;

  const rows = entitlementIds.map((entitlementId) => ({
    user_id:        userId,
    entitlement_id: entitlementId,
    is_active:      isActive,
    expires_at:     isActive ? expiresAt : null,
    updated_at:     new Date().toISOString(),
  }));

  const { error } = await supabase
    .from("user_entitlements")
    .upsert(rows, { onConflict: "user_id,entitlement_id" });

  if (error) {
    console.error("Supabase upsert error:", error.message);
    // Return 500 so RevenueCat retries delivery
    return new Response(`DB error: ${error.message}`, { status: 500 });
  }

  console.log(`Updated ${rows.length} entitlement(s) for user ${userId}: isActive=${isActive}`);
  return new Response("OK", { status: 200 });
});
