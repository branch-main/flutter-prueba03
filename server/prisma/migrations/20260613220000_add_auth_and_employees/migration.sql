CREATE TABLE "users" (
  "id" SERIAL NOT NULL,
  "email" TEXT NOT NULL,
  "name" TEXT,
  "password_hash" TEXT NOT NULL,
  "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "employees" (
  "id" SERIAL NOT NULL,
  "company_id" INTEGER NOT NULL,
  "full_name" TEXT NOT NULL,
  "document_number" TEXT,
  "position" TEXT,
  "email" TEXT,
  "phone" TEXT,
  "is_active" BOOLEAN NOT NULL DEFAULT true,
  "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "employees_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

CREATE INDEX "employees_company_id_idx" ON "employees"("company_id");

ALTER TABLE "employees"
ADD CONSTRAINT "employees_company_id_fkey"
FOREIGN KEY ("company_id") REFERENCES "companies"("id")
ON DELETE CASCADE ON UPDATE CASCADE;
