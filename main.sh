#!/bin/bash

ADDR="127.0.0.1"
SKEY="0000ffff"
PORT=" -p ${ADDR}:2222:22/tcp "

if [ "$2" == "" ] ; then echo "noop" ; exit 1 ; fi
if [ "$1" != "" ] ; then ADDR="$1" ; fi
if [ "$2" != "" ] ; then SKEY="$2" ; fi

for p in 53953 34599 ; do PORT=" ${PORT} -p ${ADDR}:${p}:${p}/tcp " ; done
for p in `seq 3931 3938` ; do PORT=" ${PORT} -p ${ADDR}:${p}:${p}/tcp " ; done

cat exec.sh | sed -e "s@SKEY=.*@SKEY='$SKEY'@ig" > exec.sh.tmp
mv exec.sh.tmp exec.sh

rm -frv src
mkdir -p src
git clone https://github.com/stoops/vpn.git src

chmod 700 *

date

docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker image prune --all --force

date
sleep 5

docker pull --platform=linux/arm64 arm64v8/debian:latest
docker build -t vpn .
docker run --privileged --restart always -d $PORT vpn

date
