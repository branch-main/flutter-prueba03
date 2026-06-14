ALTER TABLE "companies" ADD COLUMN "owner_id" INTEGER;

UPDATE "companies" SET "owner_id" = 1;

ALTER TABLE "companies" ALTER COLUMN "owner_id" SET NOT NULL;

CREATE INDEX "companies_owner_id_idx" ON "companies"("owner_id");

ALTER TABLE "companies"
ADD CONSTRAINT "companies_owner_id_fkey"
FOREIGN KEY ("owner_id") REFERENCES "users"("id")
ON DELETE CASCADE ON UPDATE CASCADE;
