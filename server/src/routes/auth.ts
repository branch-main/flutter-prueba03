import { Hono } from "hono";
import {
  createAuthToken,
  hashPassword,
  toPublicUser,
  verifyPassword,
} from "../auth";
import { prisma } from "../db";
import {
  type DataResult,
  getEmail,
  getOptionalText,
  getPassword,
  readJsonObject,
} from "../http";

type AuthData = {
  email: string;
  password: string;
  name: string | null;
};

export const authRoutes = new Hono();

async function readAuthData(request: Request): Promise<DataResult<AuthData>> {
  const result = await readJsonObject(request);
  if (result.error) return { error: result.error };

  const email = getEmail(result.data.email);
  const password = getPassword(result.data.password);

  if (!email) return { error: "Valid email is required" };
  if (!password) return { error: "Password must have at least 6 characters" };

  return {
    data: {
      email,
      password,
      name: getOptionalText(result.data.name),
    },
  };
}

authRoutes.post("/register", async (context) => {
  const result = await readAuthData(context.req.raw);
  if (result.error) return context.json({ error: result.error }, 400);

  const existingUser = await prisma.user.findUnique({
    where: { email: result.data.email },
  });

  if (existingUser) {
    return context.json({ error: "Email is already registered" }, 409);
  }

  const user = await prisma.user.create({
    data: {
      email: result.data.email,
      name: result.data.name,
      passwordHash: await hashPassword(result.data.password),
    },
    select: { id: true, email: true, name: true },
  });

  return context.json(
    {
      user: toPublicUser(user),
      token: await createAuthToken(user),
    },
    201,
  );
});

authRoutes.post("/login", async (context) => {
  const result = await readAuthData(context.req.raw);
  if (result.error) return context.json({ error: result.error }, 400);

  const user = await prisma.user.findUnique({
    where: { email: result.data.email },
  });

  if (!user) return context.json({ error: "Invalid credentials" }, 401);

  const passwordIsValid = await verifyPassword(
    result.data.password,
    user.passwordHash,
  );
  if (!passwordIsValid) {
    return context.json({ error: "Invalid credentials" }, 401);
  }

  return context.json({
    user: toPublicUser(user),
    token: await createAuthToken(user),
  });
});
