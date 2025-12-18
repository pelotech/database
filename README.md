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
helm upgrade --install database --namespace cnpg-system --create-namespace cnpg/cloudnative-pg
helm upgrade --install database .
```
