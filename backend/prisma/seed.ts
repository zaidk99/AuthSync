import "dotenv/config";
import { readFileSync } from "node:fs";
import { hash } from "bcryptjs";
import { PrismaClient } from "@prisma/client";
import { PrismaPg } from "@prisma/adapter-pg";

const databaseUrl = process.env.DATABASE_URL;
const authorPassword = process.env.SEED_AUTHOR_PASSWORD;
const adminEmail = process.env.SEED_ADMIN_EMAIL;
const adminPassword = process.env.SEED_ADMIN_PASSWORD;

if (!databaseUrl || !authorPassword || !adminEmail || !adminPassword) {
  throw new Error(
    "backend/.env must define DATABASE_URL, SEED_AUTHOR_PASSWORD, SEED_ADMIN_EMAIL, and SEED_ADMIN_PASSWORD",
  );
}

const prisma = new PrismaClient({
  adapter: new PrismaPg({ connectionString: databaseUrl }),
});

type SampleBook = {
  book_id: string;
  title: string;
  isbn: string;
  genre: string;
  publication_date: string | null;
  status: string;
  mrp: number | null;
  author_royalty_per_copy: number | null;
  total_copies_sold: number;
  total_royalty_earned: number;
  royalty_paid: number;
  royalty_pending: number;
  last_royalty_payout_date: string | null;
  print_partner: string | null;
  available_on: string[];
};

type SampleAuthor = {
  author_id: string;
  name: string;
  email: string;
  phone: string;
  city: string;
  joined_date: string;
  books: SampleBook[];
};

function toDate(value: string): Date {
  return new Date(`${value}T00:00:00.000Z`);
}

function toDateOrNull(value: string | null): Date | null {
  if (value === null) {
    return null;
  }
  return toDate(value);
}

async function main() {
  const samplePath = new URL("./sample-data.json", import.meta.url);
  const sample = JSON.parse(readFileSync(samplePath, "utf8")) as {
    authors: SampleAuthor[];
  };

  const authorPasswordHash = await hash(authorPassword, 10);
  const adminPasswordHash = await hash(adminPassword, 10);

  await prisma.$transaction(async (tx) => {
    await tx.aiCall.deleteMany();
    await tx.ticketMessage.deleteMany();
    await tx.ticket.deleteMany();
    await tx.bookPlatform.deleteMany();
    await tx.user.deleteMany();
    await tx.book.deleteMany();
    await tx.author.deleteMany();

    for (const author of sample.authors) {
      await tx.author.create({
        data: {
          author_id: author.author_id,
          name: author.name,
          email: author.email,
          phone: author.phone,
          city: author.city,
          joined_date: toDate(author.joined_date),
          books: {
            create: author.books.map((book) => ({
              book_id: book.book_id,
              title: book.title,
              isbn: book.isbn,
              genre: book.genre,
              publication_date: toDateOrNull(book.publication_date),
              status: book.status,
              mrp: book.mrp,
              author_royalty_per_copy: book.author_royalty_per_copy,
              total_copies_sold: book.total_copies_sold,
              total_royalty_earned: book.total_royalty_earned,
              royalty_paid: book.royalty_paid,
              royalty_pending: book.royalty_pending,
              last_royalty_payout_date: toDateOrNull(book.last_royalty_payout_date),
              print_partner: book.print_partner,
              platforms: {
                create: book.available_on.map((platform) => ({ platform })),
              },
            })),
          },
          user: {
            create: {
              email: author.email,
              name: author.name,
              role: "author",
              password_hash: authorPasswordHash,
            },
          },
        },
      });
    }

    await tx.user.create({
      data: {
        email: adminEmail,
        name: "BookLeaf Admin",
        role: "admin",
        password_hash: adminPasswordHash,
      },
    });
  });

  const priya = await prisma.author.findUnique({
    where: { author_id: "AUTH001" },
    include: { books: true },
  });
  const inProduction = await prisma.book.findUnique({
    where: { book_id: "BK015" },
  });
  const userCount = await prisma.user.count();

  console.log(`authors seeded, Priya book count: ${priya?.books.length ?? 0}`);
  console.log(`BK015 mrp: ${inProduction?.mrp ?? "null"}`);
  console.log(`users: ${userCount}`);
}

main()
  .catch((error: unknown) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
