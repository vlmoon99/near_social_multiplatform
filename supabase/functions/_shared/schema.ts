import { pgTable, serial, text, timestamp, jsonb, boolean, vector } from "drizzle-orm/pg-core";

export const user = pgTable("User", {
  id: text("id").primaryKey(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
  isBanned : boolean("is_banned").notNull(),
});

export const chat = pgTable("Chat", {
  id: text("id").primaryKey(),
  metadata: jsonb("metadata").notNull(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export const message = pgTable("Message", {
  id: serial("id").primaryKey(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
  messageType: text("message_type").notNull(),
  message: jsonb("message").notNull(),
  chatId: text("chat_id")
  .notNull()
  .references(() => user.id, { onDelete: "cascade" }),
  authorId: text("author_id")
    .notNull()
    .references(() => user.id, { onDelete: "cascade" }),
});

export const session = pgTable("Session", {
  userId: serial("user_id").primaryKey(),
  accountId: text("account_id")
  .notNull()
  .references(() => user.id, { onDelete: "cascade" }),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
  isActive: boolean("is_active").notNull(),
});

export const embedding = pgTable("Embedding", {
  id: serial("id").primaryKey(),
  text: text("text").notNull(),
  embedding: vector("embedding", { dimensions: 384 }).notNull(),
});

export const aiKeys = pgTable("AIKeys", {
  id: serial("id").primaryKey(),
  privateKey: text("private_key").notNull(), 
  publicKey: text("public_key").notNull(),
});

