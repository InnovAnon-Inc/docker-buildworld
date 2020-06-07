#! /usr/bin/env bash
set -exu
(( ! $# ))
cd "`dirname "$(readlink -f "$0")"`"

mkdir -pv out
dpkg --get-selections > dpkg.list
touch dpkg.log
# TODO check for existence of priv.key and pub.key
#      run ../CA/subkey.sh if necessary

command -v docker ||
curl https://raw.githubusercontent.com/InnovAnon-Inc/repo/master/get-docker.sh | bash

#trap 'docker-compose down' 0

sudo             -- \
nice -n +20      -- \
sudo -u "$USER" -- \
docker-compose up --build --force-recreate
#docker-compose up --force-recreate -d

docker-compose push
( #git pull
git add .
git commit -m "auto commit by $0"
git push ) || :

