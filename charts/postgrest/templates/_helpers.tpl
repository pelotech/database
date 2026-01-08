{{- define "database.connection" -}}
{{- $username := .Values.database.connection.username }}
{{- $password := .Values.database.connection.password }}
{{- $database := .Values.database.connection.database }}
{{- $hostname := .Values.database.connection.hostname }}
{{- printf "user=%s password=%s host=%s dbname=%s sslmode=disable" $username $password $hostname $database }}
{{- end -}}

{{- define "database.migrations" -}}
{{- $username := .Values.database.migrations.username }}
{{- $password := .Values.database.migrations.password }}
{{- $database := .Values.database.migrations.database }}
{{- $hostname := .Values.database.migrations.hostname }}
{{- printf "user=%s password=%s host=%s dbname=%s sslmode=disable" $username $password $hostname $database }}
{{- end -}}
