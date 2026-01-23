# quickstart



```shell
./example/build.sh
```

## usage

```shell
kubectl port-forward service/postgrest 30001:3000
kubectl port-forward service/postgrest 30002:8000

```

### anon - unauthenticated default

schema usage is allowed; therefore, basic information can be queried

```shell
curl localhost:30001 | jq
```

but specific data must have permissions granted

```shell
curl localhost:30001/notes | jq
```

### peek - short-lived JWT token

Using the keyserver api key, request a short-lived token

```shell
export token=$(curl -H "Authorization: Bearer a-string-secret-at-least-256-bits-long" localhost:30002/peek | jq -r '.access_token')
```

and make a request

```shell
curl -H "Authorization: Bearer $token" localhost:30001/notes | jq
```

### view - authenticated by OIDC service

first, obtain a JWT from your OIDC service. The service's JWK *must* be loaded into the keyserver to verify the token. Then, can view

```shell
curl -H "Authorization: Bearer $token" localhost:30001/notes | jq
```

but not edit

```shell
curl -H "Content-Type: application/json" -H "Authorization: Bearer $token" localhost:30001/notes -d '{"note":"meow"}'
```

### edit - authenticated by OIDC service

Now obtain a JWT with the `edit` role. You can still view

```shell
curl -H "Authorization: Bearer $token" localhost:30001/notes | jq
```

but also edit

```shell
curl -H "Content-Type: application/json" -H "Authorization: Bearer $token" localhost:30001/notes -d '{"note":"meow"}'
```
