import { Hono } from "hono";
import type { AuthUser } from "../auth";
import { prisma } from "../db";
import {
  type DataResult,
  getBoolean,
  getOptionalText,
  getText,
  readJsonObject,
} from "../http";

type EmployeePayload = {
  id: number;
  companyId: number;
  fullName: string;
  documentNumber: string | null;
  position: string | null;
  email: string | null;
  phone: string | null;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
};

type CompanyPayload = {
  id: number;
  ownerId: number;
  name: string;
  taxId: string;
  address: string | null;
  businessLine: string | null;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
  employees?: EmployeePayload[];
};

type CompanyData = {
  name: string;
  taxId: string;
  address: string | null;
  businessLine: string | null;
  isActive: boolean;
};

type EmployeeData = {
  fullName: string;
  documentNumber: string | null;
  position: string | null;
  email: string | null;
  phone: string | null;
  isActive: boolean;
};

export const companyRoutes = new Hono<{ Variables: { user: AuthUser } }>();

function toEmployee(employee: EmployeePayload) {
  return {
    id: employee.id,
    companyId: employee.companyId,
    fullName: employee.fullName,
    documentNumber: employee.documentNumber,
    position: employee.position,
    email: employee.email,
    phone: employee.phone,
    isActive: employee.isActive,
  };
}

function toCompany(company: CompanyPayload) {
  const data = {
    id: company.id,
    name: company.name,
    taxId: company.taxId,
    address: company.address,
    businessLine: company.businessLine,
    isActive: company.isActive,
  };

  if (!company.employees) return data;

  return {
    ...data,
    employees: company.employees.map(toEmployee),
  };
}

function getId(value: string) {
  const id = Number(value);
  return Number.isInteger(id) && id > 0 ? id : null;
}

async function readCompanyData(
  request: Request,
): Promise<DataResult<CompanyData>> {
  const result = await readJsonObject(request);
  if (result.error) return { error: result.error };

  const name = getText(result.data.name);
  const taxId = getText(result.data.taxId);

  if (!name) return { error: "Name is required" };
  if (!taxId) return { error: "Tax ID is required" };

  return {
    data: {
      name,
      taxId,
      address: getOptionalText(result.data.address),
      businessLine: getOptionalText(result.data.businessLine),
      isActive: getBoolean(result.data.isActive),
    },
  };
}

async function readEmployeeData(
  request: Request,
): Promise<DataResult<EmployeeData>> {
  const result = await readJsonObject(request);
  if (result.error) return { error: result.error };

  const fullName = getText(result.data.fullName);

  if (!fullName) return { error: "Full name is required" };

  return {
    data: {
      fullName,
      documentNumber: getOptionalText(result.data.documentNumber),
      position: getOptionalText(result.data.position),
      email: getOptionalText(result.data.email),
      phone: getOptionalText(result.data.phone),
      isActive: getBoolean(result.data.isActive),
    },
  };
}

async function createCompany(ownerId: number, data: CompanyData) {
  const company = await prisma.company.create({ data: { ...data, ownerId } });
  return toCompany(company);
}

async function updateCompany(
  ownerId: number,
  companyId: number,
  data: CompanyData,
) {
  const result = await prisma.company.updateMany({
    where: { id: companyId, ownerId },
    data,
  });

  if (result.count === 0) return null;

  const company = await prisma.company.findFirst({
    where: { id: companyId, ownerId },
  });

  return company ? toCompany(company) : null;
}

async function getOwnedCompany(ownerId: number, companyId: number) {
  return await prisma.company.findFirst({
    where: { id: companyId, ownerId },
    select: { id: true },
  });
}

async function getCompanyEmployees(ownerId: number, companyId: number) {
  const company = await getOwnedCompany(ownerId, companyId);
  if (!company) return null;

  const employees = await prisma.employee.findMany({
    where: { companyId },
    orderBy: { id: "desc" },
  });

  return employees.map(toEmployee);
}

async function createEmployee(
  ownerId: number,
  companyId: number,
  data: EmployeeData,
) {
  const company = await getOwnedCompany(ownerId, companyId);
  if (!company) return null;

  const employee = await prisma.employee.create({
    data: {
      ...data,
      companyId,
    },
  });

  return toEmployee(employee);
}

async function updateEmployee(
  ownerId: number,
  companyId: number,
  employeeId: number,
  data: EmployeeData,
) {
  const company = await getOwnedCompany(ownerId, companyId);
  if (!company) return null;

  const employee = await prisma.employee.findFirst({
    where: { id: employeeId, companyId },
    select: { id: true },
  });

  if (!employee) return null;

  const updatedEmployee = await prisma.employee.update({
    where: { id: employeeId },
    data,
  });

  return toEmployee(updatedEmployee);
}

async function deleteEmployee(
  ownerId: number,
  companyId: number,
  employeeId: number,
) {
  const company = await getOwnedCompany(ownerId, companyId);
  if (!company) return false;

  const result = await prisma.employee.deleteMany({
    where: { id: employeeId, companyId },
  });

  return result.count > 0;
}

companyRoutes.get("/", async (context) => {
  const user = context.get("user");
  const search = getOptionalText(context.req.query("search"));
  const companies = await prisma.company.findMany({
    where: {
      ownerId: user.id,
      ...(search
        ? {
            OR: [
              { name: { contains: search, mode: "insensitive" } },
              { taxId: { contains: search, mode: "insensitive" } },
            ],
          }
        : {}),
    },
    orderBy: { id: "desc" },
  });

  return context.json(companies.map(toCompany));
});

companyRoutes.post("/", async (context) => {
  const user = context.get("user");
  const result = await readCompanyData(context.req.raw);
  if (result.error) return context.json({ error: result.error }, 400);

  return context.json(await createCompany(user.id, result.data), 201);
});

companyRoutes.get("/:id/employees", async (context) => {
  const user = context.get("user");
  const companyId = getId(context.req.param("id"));
  if (!companyId) return context.json({ error: "Company not found" }, 404);

  const employees = await getCompanyEmployees(user.id, companyId);
  if (!employees) return context.json({ error: "Company not found" }, 404);

  return context.json(employees);
});

companyRoutes.post("/:id/employees", async (context) => {
  const user = context.get("user");
  const companyId = getId(context.req.param("id"));
  if (!companyId) return context.json({ error: "Company not found" }, 404);

  const result = await readEmployeeData(context.req.raw);
  if (result.error) return context.json({ error: result.error }, 400);

  const employee = await createEmployee(user.id, companyId, result.data);
  if (!employee) return context.json({ error: "Company not found" }, 404);

  return context.json(employee, 201);
});

companyRoutes.put("/:id/employees/:employeeId", async (context) => {
  const user = context.get("user");
  const companyId = getId(context.req.param("id"));
  const employeeId = getId(context.req.param("employeeId"));
  if (!companyId || !employeeId) {
    return context.json({ error: "Employee not found" }, 404);
  }

  const result = await readEmployeeData(context.req.raw);
  if (result.error) return context.json({ error: result.error }, 400);

  const employee = await updateEmployee(
    user.id,
    companyId,
    employeeId,
    result.data,
  );
  if (!employee) return context.json({ error: "Employee not found" }, 404);

  return context.json(employee);
});

companyRoutes.delete("/:id/employees/:employeeId", async (context) => {
  const user = context.get("user");
  const companyId = getId(context.req.param("id"));
  const employeeId = getId(context.req.param("employeeId"));
  if (!companyId || !employeeId) {
    return context.json({ error: "Employee not found" }, 404);
  }

  const deleted = await deleteEmployee(user.id, companyId, employeeId);
  if (!deleted) return context.json({ error: "Employee not found" }, 404);

  return context.json({ ok: true });
});

companyRoutes.get("/:id", async (context) => {
  const user = context.get("user");
  const companyId = getId(context.req.param("id"));
  if (!companyId) return context.json({ error: "Company not found" }, 404);

  const company = await prisma.company.findFirst({
    where: { id: companyId, ownerId: user.id },
    include: { employees: { orderBy: { id: "desc" } } },
  });
  if (!company) return context.json({ error: "Company not found" }, 404);

  return context.json(toCompany(company));
});

companyRoutes.put("/:id", async (context) => {
  const user = context.get("user");
  const companyId = getId(context.req.param("id"));
  if (!companyId) return context.json({ error: "Company not found" }, 404);

  const result = await readCompanyData(context.req.raw);
  if (result.error) return context.json({ error: result.error }, 400);

  const company = await updateCompany(user.id, companyId, result.data);
  if (!company) return context.json({ error: "Company not found" }, 404);

  return context.json(company);
});

companyRoutes.delete("/:id", async (context) => {
  const user = context.get("user");
  const companyId = getId(context.req.param("id"));
  if (!companyId) return context.json({ error: "Company not found" }, 404);

  const result = await prisma.company.deleteMany({
    where: { id: companyId, ownerId: user.id },
  });
  if (result.count === 0) {
    return context.json({ error: "Company not found" }, 404);
  }

  return context.json({ ok: true });
});
