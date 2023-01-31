#!/bin/bash

mvn clean install -Dmaven.test.skip=true

if [ ! -z "$1" ]
then
      echo "\$1 is NOT empty - $1"
      export DOCKER_IMAGE_VERSION="$1"
else
      echo "\$1 is empty"
      export DOCKER_IMAGE_VERSION="v0.1"
fi

aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 613477150601.dkr.ecr.ap-southeast-1.amazonaws.com
docker build . -t x-ray-world-demo:latest
docker tag x-ray-world-demo:latest 613477150601.dkr.ecr.ap-southeast-1.amazonaws.com/x-ray-world-demo:$DOCKER_IMAGE_VERSION
docker push 613477150601.dkr.ecr.ap-southeast-1.amazonaws.com/x-ray-world-demo:$DOCKER_IMAGE_VERSION
