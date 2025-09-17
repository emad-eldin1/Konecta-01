-- Create schema, example table. This runs on first container initialization.
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS books (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  author TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Example: create a restricted role (optional; Postgres already uses POSTGRES_USER)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO book_user;

