# database
PostgreSQL + PostgREST setup and configuration patterns

## quickstart

```shell
kind create cluster --name pelotech

docker build -t pelotech/goose:latest -f images/goose.dockerfile .

kind load docker-image pelotech/goose:latest --name pelotech

helm upgrade --install cnpg \
  --namespace cnpg-system   \
  --create-namespace        \
  --wait                    \
  --timeout 1m              \
  cnpg/cloudnative-pg

helm dependency build example/cloudnative-pg

helm upgrade --install cluster \
  --namespace default          \
  --wait                       \
  --timeout 5m                 \
  example/cloudnative-pg

kubectl create configmap migrations \
  --namespace default               \
  --from-file=example/migrations

helm upgrade --install postgrest \
  --namespace default            \
  ./
```

## usage

```shell
kubectl port-forward service/postgrest 30001:3000
```

### anonymous

schema usage is allowed; therefore, basic information can be queried

```shell
curl localhost:30001 | jq
```

but specific data must have permissions granted

```shell
curl localhost:30001/notes | jq
```

### authenticated - view

first, construct a JWT

```shell
secret=a-string-secret-at-least-256-bits-long
_base64 () { openssl base64 -e -A | tr '+/' '-_' | tr -d '='; }
header=$(echo -n '{"alg":"HS256","typ":"JWT"}' | _base64)
payload=$(echo -n "{\"role\":\"view\"}" | _base64)
signature=$(echo -n "$header.$payload" | openssl dgst -sha256 -hmac "$secret" -binary | _base64)
token=$(echo -n "$header.$payload.$signature")
```

you can now view

```shell
curl -H "Authorization: Bearer $token" localhost:30001/notes | jq
```

```shell
curl -H "Content-Type: application/json" -H "Authorization: Bearer $token" localhost:30001/notes -d '{"note":"meow"}'
```

### authenticated - edit

now construct a JWT with the edit role

```shell
payload=$(echo -n "{\"role\":\"edit\"}" | _base64)
signature=$(echo -n "$header.$payload" | openssl dgst -sha256 -hmac "$secret" -binary | _base64)
token=$(echo -n "$header.$payload.$signature")
```

you can still view

```shell
curl -H "Authorization: Bearer $token" localhost:30001/notes | jq
```

but also edit

```shell
curl -H "Content-Type: application/json" -H "Authorization: Bearer $token" localhost:30001/notes -d '{"note":"meow"}'
```
