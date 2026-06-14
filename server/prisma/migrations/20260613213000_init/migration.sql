CREATE SCHEMA IF NOT EXISTS "public";

CREATE TABLE "companies" (
  "id" SERIAL NOT NULL,
  "name" TEXT NOT NULL,
  "tax_id" TEXT NOT NULL,
  "address" TEXT,
  "business_line" TEXT,
  "is_active" BOOLEAN NOT NULL DEFAULT true,
  "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "companies_pkey" PRIMARY KEY ("id")
);
