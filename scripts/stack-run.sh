#!/bin/bash

SOURCE=$(dirname $(dirname "$0"))
DOCKER=${SOURCE}/docker
PROJECT=iroha

docker stack deploy --prune --compose-file ${DOCKER}/docker-compose.yml ${PROJECT}
