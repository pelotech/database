{{ define "database.connection" }}
{{ $username := .Values.database.connection.username }}
{{ $password := .Values.database.connection.password }}
{{ $database := .Values.database.connection.database }}
{{ $hostname := .Values.database.connection.hostname }}
{{ printf "user=%s password=%s host=%s dbname=%s sslmode=disable" $username $password $hostname $database }}
{{ end }}

{{ define "database.migrations" }}
{{ $username := .Values.database.migrations.username }}
{{ $password := .Values.database.migrations.password }}
{{ $database := .Values.database.migrations.database }}
{{ $hostname := .Values.database.migrations.hostname }}
{{ printf "user=%s password=%s host=%s dbname=%s sslmode=disable" $username $password $hostname $database }}
{{ end }}

{{ define "application.jwk.public.retrieval" }}
{{ $location := .Values.application.jwk.public }}
{{ $present := not (empty $location) }}
{{ if $present }}
- name: jwk-public-retrieval
  image: alpine/curl
  imagePullPolicy: IfNotPresent
  command:
    - /bin/sh
    - -c
    - "curl --location {{ $location }} > /etc/opt/postgrest/certificates/jwk.json"
  volumeMounts:
    - mountPath: /etc/opt/postgrest/certificates
      name: certificates
{{ end }}
{{ end }}

{{ define "application.jwt.secret.reference" }}
{{ $location := .Values.application.jwk.public }}
{{ $present := not (empty $location) }}
- name: PGRST_JWT_SECRET
{{ if $present }}
  value: @/etc/opt/postgrest/certificates/jwks.json
{{ else }}
  valueFrom:
    secretKeyRef:
      key: jwt.secret
      name: authentication
{{ end }}
{{ end }}

{{ define "database.migrations.container" }}
{{ if .Values.database.migrations.enabled }}
- name: migrations
  image: pelotech/goose
  imagePullPolicy: IfNotPresent
  command:
    - /bin/goose
    - postgres
    - up
  env:
    - name: GOOSE_DBSTRING
      valueFrom:
        secretKeyRef:
          key: connection
          name: migrations
    - name: GOOSE_MIGRATION_DIR
      value: migrations
  volumeMounts:
    - mountPath: /migrations
      name: migrations
{{ end }}
{{ end }}
