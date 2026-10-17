import dotenv from "dotenv";

dotenv.config();

function required(name: string, value: string | undefined): string {
  if (!value) {
    throw new Error(`${name} is missing from backend/.env`);
  }
  return value;
}

export const ENV = {
  PORT: process.env.PORT || "5001",
  DATABASE_URL: required("DATABASE_URL", process.env.DATABASE_URL),
  JWT_SECRET: required("JWT_SECRET", process.env.JWT_SECRET),
  CLIENT_ORIGIN: process.env.CLIENT_ORIGIN || "http://localhost:5173",
};
