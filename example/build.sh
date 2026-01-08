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

helm template --namespace default postgrest "$directory/charts/postgrest" | \
  tee "$(pwd)/example.manifest.yaml" | \
  kubectl apply -f -
