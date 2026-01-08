# quickstart



```shell
./example/build.sh
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

but not edit

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
