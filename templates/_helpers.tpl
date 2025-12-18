{{/*
Formats a PostgreSQL connection string for non-superuser database connections
*/}}
{{- define "postgrest.database.connection" -}}
{{- $user := .Values.postgrest.database.username }}
{{- $pass := .Values.postgrest.database.password }}
{{- $name := .Values.postgrest.database.database }}
{{- printf "user=%s password=%s host=%s-cluster-rw dbname=%s sslmode=disable" $user $pass .Chart.Name $name }}
{{- end }}

{{/*
Formats a PostgreSQL connection string for superuser database connections
*/}}
{{- define "postgrest.superuser.connection" -}}
{{- $user := .Values.goose.username }}
{{- $pass := .Values.goose.password }}
{{- $name := .Values.goose.database }}
{{- printf "user=%s password=%s host=%s-cluster-rw dbname=%s sslmode=disable" $user $pass .Chart.Name $name }}
{{- end }}

{{- define "postgrest.security.configuration" -}}
{{- $schema := required "schema is required" .schema | quote }}
{{- $table := required "table is required" .table | quote }}
{{- $view := required "view is required" .view | quote }}
{{- $edit := required "view is required" .view | quote }}
-- +goose Up
-- +goose StatementBegin
GRANT SELECT ON {{ $schema }}.{{ $table }} TO {{ $view }};
GRANT INSERT, UPDATE, DELETE ON {{ $schema }}.{{ $table }} TO {{ $edit }};
ALTER TABLE {{ $schema }}.{{ $table }} ADD COLUMN IF NOT EXISTS authorized TEXT DEFAULT authz();
ALTER TABLE {{ $schema }}.{{ $table }} ENABLE ROW LEVEL SECURITY;
CREATE POLICY enforce_authorization ON {{ $schema }}.{{ $table }} FOR ALL USING (authorized = authz());
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP POLICY enforce_authorization ON {{ $schema }}.{{ $table }};
ALTER TABLE {{ $schema }}.{{ $table }} DISABLE ROW LEVEL SECURITY;
-- +goose StatementEnd
{{- end -}}
