#!/bin/bash

SOURCE=$(dirname $(dirname "$0"))
DOCKER=${SOURCE}/docker
PROJECT=iroha

docker-compose -f ${DOCKER}/docker-compose.yml -p ${PROJECT} --project-directory ${SOURCE} up --force-recreate -d
