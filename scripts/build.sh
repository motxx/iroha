#!/bin/bash

SOURCE=$(dirname $(dirname "$0"))
BUILD=${SOURCE}/build
TINY=${SOURCE}/docker/tiny
RELEASE=${TINY}/iroha

rm -rf ${BUILD} ${SOURCE}/external

cmake -DCMAKE_BUILD_TYPE=Release -H${SOURCE} -B${BUILD}
cmake --build ${BUILD} --target irohad --clean-first
cmake --build ${BUILD} --target iroha-cli

# copy libs used by iroha
LIBS=$(ldd ${BUILD}/bin/irohad | cut -f 2 | cut -d " " -f 3)
mkdir -p ${RELEASE}/lib
cp -H ${LIBS} ${RELEASE}/lib

rsync -avr ${BUILD}/bin ${RELEASE}

docker build -t hyperledger/iroha-docker ${TINY}

# clean up
rm -rf ${TINY}/iroha
