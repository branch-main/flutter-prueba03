import { Hono, type MiddlewareHandler } from "hono";
import { cors } from "hono/cors";
import { getAuthenticatedUser, type AuthUser } from "./auth";
import { prisma } from "./db";
import { authRoutes } from "./routes/auth";
import { companyRoutes } from "./routes/companies";

const port = Number(Bun.env.PORT ?? 3000);
const host = Bun.env.HOST ?? "0.0.0.0";

type AppVariables = {
  user: AuthUser;
};

const app = new Hono<{ Variables: AppVariables }>();

app.use(
  "*",
  cors({
    origin: "*",
    allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allowHeaders: ["Content-Type", "Authorization"],
  }),
);

app.get("/health", async (context) => {
  await prisma.$queryRaw`SELECT 1`;
  return context.json({ status: "ok" });
});

app.route("/api/auth", authRoutes);

const requireAuth: MiddlewareHandler<{ Variables: AppVariables }> = async (
  context,
  next,
) => {
  const user = await getAuthenticatedUser(context.req.raw);
  if (!user) return context.json({ error: "Unauthorized" }, 401);

  context.set("user", user);
  await next();
};

app.use("/api/companies", requireAuth);
app.use("/api/companies/*", requireAuth);
app.route("/api/companies", companyRoutes);

app.notFound((context) => context.json({ error: "Route not found" }, 404));

app.onError((error, context) => {
  console.error(error);
  return context.json({ error: "Internal server error" }, 500);
});

Bun.serve({
  host,
  port,
  fetch: app.fetch,
});

console.log(`Server listening on http://${host}:${port}`);
