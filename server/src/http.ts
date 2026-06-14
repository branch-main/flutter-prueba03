export type DataResult<T> =
  | { data: T; error?: never }
  | { data?: never; error: string };

export function getText(value: unknown) {
  if (typeof value !== "string") return null;

  const text = value.trim();
  return text.length > 0 ? text : null;
}

export function getEmail(value: unknown) {
  const email = getText(value)?.toLowerCase();
  if (!email) return null;
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) return null;

  return email;
}

export function getPassword(value: unknown) {
  if (typeof value !== "string") return null;
  return value.length >= 6 ? value : null;
}

export function getOptionalText(value: unknown) {
  if (value == null) return null;
  return getText(value);
}

export function getBoolean(value: unknown) {
  if (typeof value === "boolean") return value;
  if (typeof value === "number") return value !== 0;
  return true;
}

export async function readJsonObject(
  request: Request,
): Promise<DataResult<Record<string, unknown>>> {
  try {
    const json = await request.json();
    if (!json || typeof json !== "object" || Array.isArray(json)) {
      return { error: "Invalid JSON" };
    }

    return { data: json as Record<string, unknown> };
  } catch {
    return { error: "Invalid JSON" };
  }
}
