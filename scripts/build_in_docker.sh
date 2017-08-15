#!/bin/bash

SOURCE=$(dirname $(dirname "$0"))
BUILD=${SOURCE}/build
TINY=${SOURCE}/docker/tiny
RELEASE=${TINY}/iroha

# run dev container to build iroha
docker run -i \
    -v ${IROHA_HOME}/docker/build:/build \
    -v ${IROHA_HOME}:/opt/iroha \
    -v ${TINY}:/tiny \
    -v ${RELEASE}:/release \
    hyperledger/iroha-docker-develop \
    sh << EOD
    # clean current binaries
    rm -rf /build/* /opt/iroha/external

    # make iroha
    cd /build
    cmake /opt/iroha -DCMAKE_BUILD_TYPE=Release
    make -j 10

    # copy libs used by iroha
    LIBS=$(ldd /build/bin/iroha-main | cut -f 2 | cut -d " " -f 3)
    mkdir -p /release/lib
    cp -H $LIBS /release/lib

    # copy config
    mkdir -p /release/config
    cp /opt/iroha/config/sumeragi.json /release/config/sumeragi.json
    cp /opt/iroha/config/config.json /release/config/config.json

    rsync -avr /build/bin /release
    rsync -avr /tiny/scripts /release
EOD

# create iroha-docker image
docker build -t hyperledger/iroha-docker ${TINY}

# clean up
rm -rf ${TINY}/iroha

