-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS "public"."notes" ("note" TEXT);
GRANT SELECT ON "public"."notes" TO view;
GRANT SELECT, INSERT, UPDATE ON "public"."notes" TO edit;
NOTIFY pgrst, 'reload schema';
-- +goose StatementEnd
