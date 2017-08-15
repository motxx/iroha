#!/bin/bash

SOURCE=$(dirname $(dirname "$0"))
DOCKER=${SOURCE}/docker
USER=$(whoami)
USERID=$(id -u ${USER})

docker-compose -f ${DOCKER}/docker-compose-dev.yml -p iroha --project-directory ${SOURCE} up --scale postgres=0 --scale redis=0 --force-recreate -d
docker-compose -f ${DOCKER}/docker-compose-dev.yml -p iroha --project-directory ${SOURCE} exec node adduser --disabled-password --gecos "" ${USER} --uid ${USERID}
docker-compose -f ${DOCKER}/docker-compose-dev.yml -p iroha --project-directory ${SOURCE} exec --user ${USER} node /bin/bash
