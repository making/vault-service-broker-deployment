#!/bin/bash
set -e
cf local stage vault-service-broker -p vault-service-broker
cf local export vault-service-broker -r making/vault-service-broker
docker push making/vault-service-broker
