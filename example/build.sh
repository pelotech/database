#!/usr/bin/env bash

directory=$(git rev-parse --show-toplevel)

kind delete cluster --name example
kind create cluster --name example

helm dependency build "$directory/charts/postgrest"

helm upgrade \
  --install cnpg \
  --namespace cnpg-system \
  --create-namespace \
  --wait \
  --timeout 1m \
  cnpg/cloudnative-pg

# shellcheck disable=SC2164
(cd "$directory/example/migrations"; docker build -t ghcr.io/pelotech/goose:example .)
kind load docker-image ghcr.io/pelotech/goose:example --name example

# shellcheck disable=SC2164
(cd "$directory/charts/postgrest/keyserver"; docker build -t ghcr.io/pelotech/postgrest/keyserver:example .)
kind load docker-image ghcr.io/pelotech/postgrest/keyserver:example --name example

helm template --namespace default postgrest "$directory/charts/postgrest" | \
  tee "$(pwd)/example.manifest.yaml" | \
  kubectl apply -f -
