#!/bin/bash

SOURCE=$(dirname $(dirname "$0"))
DOCKER=${SOURCE}/docker
USER=$(whoami)
USERID=$(id -u ${USER})
PROJECT=irohadev

docker-compose -f ${DOCKER}/docker-compose-dev.yml -p ${PROJECT} --project-directory ${SOURCE} up --force-recreate -d
docker-compose -f ${DOCKER}/docker-compose-dev.yml -p ${PROJECT} --project-directory ${SOURCE} exec node adduser --disabled-password --gecos "" ${USER} --uid ${USERID}
docker-compose -f ${DOCKER}/docker-compose-dev.yml -p ${PROJECT} --project-directory ${SOURCE} exec --user ${USER} node /bin/bash
