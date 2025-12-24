{{- define "postgrest.application.connection" -}}
{{ $username := .Values.database.application.username }}
{{ $password := .Values.database.application.password }}
{{ $database := .Values.database.application.database }}
{{ $hostname := .Values.database.application.hostname }}
{{ printf "user=%s password=%s host=%s-%s dbname=%s sslmode=disable" $username $password .Release.Name $hostname $database }}
{{ end }}

{{ define "postgrest.permissions.connection" }}
{{ $username := .Values.database.permissions.username }}
{{ $password := .Values.database.permissions.password }}
{{ $database := .Values.database.permissions.database }}
{{ $hostname := .Values.database.permissions.hostname }}
{{ printf "user=%s password=%s host=%s-%s dbname=%s sslmode=disable" $username $password .Release.Name $hostname $database }}
{{ end }}
