export type Role = "admin" | "author";

export interface JwtPayload {
  userId: string;
  role: Role;
  authorId: string | null;
}
