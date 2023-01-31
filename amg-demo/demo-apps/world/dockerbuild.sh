#!/bin/bash

get_current_directory() {
    current_file="${PWD}/${0}"
    echo "${current_file%/*}"
}

CWD=$(get_current_directory)
echo "$CWD"

cd $CWD

if [ ! -z "$1" ]
then
      echo "\$1 is NOT empty - $1"
      export DOCKER_IMAGE_VERSION="$1"
else
      echo "\$1 is empty"
      export DOCKER_IMAGE_VERSION="v0.1"
fi

aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 613477150601.dkr.ecr.ap-southeast-1.amazonaws.com
docker build . -t grafana-demo-world:latest
docker tag grafana-demo-world:latest 613477150601.dkr.ecr.ap-southeast-1.amazonaws.com/grafana-demo-world:$DOCKER_IMAGE_VERSION
docker push 613477150601.dkr.ecr.ap-southeast-1.amazonaws.com/grafana-demo-world:$DOCKER_IMAGE_VERSION
