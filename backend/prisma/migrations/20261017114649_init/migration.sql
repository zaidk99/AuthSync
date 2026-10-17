-- CreateEnum
CREATE TYPE "Role" AS ENUM ('admin', 'author');

-- CreateEnum
CREATE TYPE "TicketStatus" AS ENUM ('open', 'in_progress', 'resolved', 'closed');

-- CreateEnum
CREATE TYPE "Priority" AS ENUM ('Critical', 'High', 'Medium', 'Low');

-- CreateEnum
CREATE TYPE "SetBy" AS ENUM ('ai', 'admin');

-- CreateEnum
CREATE TYPE "AiState" AS ENUM ('pending', 'ok', 'failed');

-- CreateEnum
CREATE TYPE "Visibility" AS ENUM ('public', 'internal');

-- CreateEnum
CREATE TYPE "AiPurpose" AS ENUM ('classify', 'draft');

-- CreateEnum
CREATE TYPE "TicketCategory" AS ENUM ('Royalty & Payments', 'ISBN & Metadata Issues', 'Printing & Quality', 'Distribution & Availability', 'Book Status & Production Updates', 'General Inquiry');

-- CreateTable
CREATE TABLE "authors" (
    "author_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "joined_date" DATE NOT NULL,

    CONSTRAINT "authors_pkey" PRIMARY KEY ("author_id")
);

-- CreateTable
CREATE TABLE "books" (
    "book_id" TEXT NOT NULL,
    "author_id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "isbn" TEXT NOT NULL,
    "genre" TEXT NOT NULL,
    "publication_date" DATE,
    "status" TEXT NOT NULL,
    "mrp" INTEGER,
    "author_royalty_per_copy" INTEGER,
    "total_copies_sold" INTEGER NOT NULL,
    "total_royalty_earned" INTEGER NOT NULL,
    "royalty_paid" INTEGER NOT NULL,
    "royalty_pending" INTEGER NOT NULL,
    "last_royalty_payout_date" DATE,
    "print_partner" TEXT,

    CONSTRAINT "books_pkey" PRIMARY KEY ("book_id")
);

-- CreateTable
CREATE TABLE "book_platforms" (
    "book_id" TEXT NOT NULL,
    "platform" TEXT NOT NULL,

    CONSTRAINT "book_platforms_pkey" PRIMARY KEY ("book_id","platform")
);

-- CreateTable
CREATE TABLE "users" (
    "user_id" BIGSERIAL NOT NULL,
    "email" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "role" "Role" NOT NULL,
    "password_hash" TEXT NOT NULL,
    "author_id" TEXT,

    CONSTRAINT "users_pkey" PRIMARY KEY ("user_id")
);

-- CreateTable
CREATE TABLE "tickets" (
    "ticket_id" BIGSERIAL NOT NULL,
    "author_id" TEXT NOT NULL,
    "book_id" TEXT,
    "subject" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "status" "TicketStatus" NOT NULL DEFAULT 'open',
    "category" "TicketCategory",
    "category_set_by" "SetBy",
    "priority" "Priority",
    "priority_set_by" "SetBy",
    "ai_state" "AiState" NOT NULL DEFAULT 'pending',
    "assigned_user_id" BIGINT,
    "draft_body" TEXT,
    "draft_updated_at" TIMESTAMPTZ(3),
    "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "tickets_pkey" PRIMARY KEY ("ticket_id")
);

-- CreateTable
CREATE TABLE "ticket_messages" (
    "message_id" BIGSERIAL NOT NULL,
    "ticket_id" BIGINT NOT NULL,
    "sender_user_id" BIGINT NOT NULL,
    "body" TEXT NOT NULL,
    "visibility" "Visibility" NOT NULL,
    "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ticket_messages_pkey" PRIMARY KEY ("message_id")
);

-- CreateTable
CREATE TABLE "ai_calls" (
    "ai_call_id" BIGSERIAL NOT NULL,
    "ticket_id" BIGINT NOT NULL,
    "purpose" "AiPurpose" NOT NULL,
    "model" TEXT NOT NULL,
    "prompt_tokens" INTEGER,
    "completion_tokens" INTEGER,
    "success" BOOLEAN NOT NULL,
    "error_message" TEXT,
    "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ai_calls_pkey" PRIMARY KEY ("ai_call_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "authors_email_key" ON "authors"("email");

-- CreateIndex
CREATE INDEX "books_author_id_idx" ON "books"("author_id");

-- CreateIndex
CREATE INDEX "book_platforms_platform_idx" ON "book_platforms"("platform");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "users_author_id_key" ON "users"("author_id");

-- CreateIndex
CREATE INDEX "tickets_author_id_idx" ON "tickets"("author_id");

-- CreateIndex
CREATE INDEX "tickets_book_id_idx" ON "tickets"("book_id");

-- CreateIndex
CREATE INDEX "tickets_assigned_user_id_idx" ON "tickets"("assigned_user_id");

-- CreateIndex
CREATE INDEX "tickets_status_idx" ON "tickets"("status");

-- CreateIndex
CREATE INDEX "ticket_messages_ticket_id_idx" ON "ticket_messages"("ticket_id");

-- CreateIndex
CREATE INDEX "ticket_messages_sender_user_id_idx" ON "ticket_messages"("sender_user_id");

-- CreateIndex
CREATE INDEX "ai_calls_ticket_id_idx" ON "ai_calls"("ticket_id");

-- AddForeignKey
ALTER TABLE "books" ADD CONSTRAINT "books_author_id_fkey" FOREIGN KEY ("author_id") REFERENCES "authors"("author_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "book_platforms" ADD CONSTRAINT "book_platforms_book_id_fkey" FOREIGN KEY ("book_id") REFERENCES "books"("book_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "users" ADD CONSTRAINT "users_author_id_fkey" FOREIGN KEY ("author_id") REFERENCES "authors"("author_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tickets" ADD CONSTRAINT "tickets_author_id_fkey" FOREIGN KEY ("author_id") REFERENCES "authors"("author_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tickets" ADD CONSTRAINT "tickets_book_id_fkey" FOREIGN KEY ("book_id") REFERENCES "books"("book_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tickets" ADD CONSTRAINT "tickets_assigned_user_id_fkey" FOREIGN KEY ("assigned_user_id") REFERENCES "users"("user_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ticket_messages" ADD CONSTRAINT "ticket_messages_ticket_id_fkey" FOREIGN KEY ("ticket_id") REFERENCES "tickets"("ticket_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ticket_messages" ADD CONSTRAINT "ticket_messages_sender_user_id_fkey" FOREIGN KEY ("sender_user_id") REFERENCES "users"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ai_calls" ADD CONSTRAINT "ai_calls_ticket_id_fkey" FOREIGN KEY ("ticket_id") REFERENCES "tickets"("ticket_id") ON DELETE CASCADE ON UPDATE CASCADE;
