import { jwtVerify, SignJWT } from "jose";
import { prisma } from "./db";

const jwtSecret = Bun.env.JWT_SECRET;
const jwtExpiresIn = Bun.env.JWT_EXPIRES_IN ?? "7d";

if (!jwtSecret) {
  throw new Error("JWT_SECRET is required");
}

const secretKey = new TextEncoder().encode(jwtSecret);

export type AuthUser = {
  id: number;
  email: string;
  name: string | null;
};

export function toPublicUser(user: AuthUser) {
  return {
    id: user.id,
    email: user.email,
    name: user.name,
  };
}

export async function hashPassword(password: string) {
  return await Bun.password.hash(password);
}

export async function verifyPassword(password: string, hash: string) {
  return await Bun.password.verify(password, hash);
}

export async function createAuthToken(user: AuthUser) {
  return await new SignJWT({ email: user.email })
    .setProtectedHeader({ alg: "HS256" })
    .setSubject(String(user.id))
    .setIssuedAt()
    .setExpirationTime(jwtExpiresIn)
    .sign(secretKey);
}

export async function getAuthenticatedUser(request: Request) {
  const authorization = request.headers.get("Authorization");
  const token = authorization?.match(/^Bearer\s+(.+)$/i)?.[1];

  if (!token) return null;

  try {
    const { payload } = await jwtVerify(token, secretKey);
    const userId = Number(payload.sub);

    if (!Number.isInteger(userId)) return null;

    return await prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, email: true, name: true },
    });
  } catch {
    return null;
  }
}
