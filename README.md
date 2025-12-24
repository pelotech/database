# database
PostgreSQL + PostgREST setup and configuration patterns

## quickstart

```shell
kind create cluster --name pelotech
kubectl cluster-info --context kind-pelotech
kubectl krew install cnpg
docker build -t pelotech/goose:latest -f goose.dockerfile .
kind load docker-image pelotech/goose:latest --name pelotech
helm dependency update
helm upgrade --install database --namespace cnpg-system --create-namespace --wait --timeout 5m cnpg/cloudnative-pg
helm upgrade --install --wait --timeout 5m database .
```

Wait for the database cluster to come online. Then port forward both keycloak and postgrest

```shell
kubectl port-forward service/keycloak 8080:8080
```

```shell
kubectl port-forward service/database-postgrest 3000:3000
```

Test an anonymous GET

```shell
curl --location 'localhost:3000/examples'
```

Test an anonymous POST. This request should fail

```shell
curl --location -X POST -H 'Content-Type: application/json' 'localhost:3000/examples' -d {}
```

Test an authenticated GET with a bad token. This request should fail

```shell
token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMn0.KMUFsIDTnFmyG3nMiGM6H9FNFUROf3wh7SmqJp-QV30
curl --location -H "Authorization: Bearer ${token}" 'localhost:3000/examples'
```

Grab an access token ...

```shell
token=$(curl --location 'localhost:8080/realms/demo/protocol/openid-connect/token' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'client_id=postgrest' \
--data-urlencode 'grant_type=password' \
--data-urlencode 'client_secret=ec78c6bb-8339-4bed-9b1b-e973d27107dc' \
--data-urlencode 'scope=openid' \
--data-urlencode 'username=test.user' \
--data-urlencode 'password=password123' | jq -r '.access_token')
```

... and test an authenticated GET and POST. The second GET should return the authorized user id.

```shell
curl --location -H "Authorization: Bearer ${token}" 'localhost:3000/examples'
curl --location -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer ${token}" 'localhost:3000/examples' -d {}
curl --location -H "Authorization: Bearer ${token}" 'localhost:3000/examples'
```

Finally, confirm unauthorized users cannot read the protected rows. The result should be empty.

```shell
curl --location 'localhost:3000/examples'
```



## troubleshooting

### "Could not find the table 'public.examples' in the schema cache"

Restart the pods to get the latest database schema information

```shell
kubectl rollout restart deployment/postgrest
```
