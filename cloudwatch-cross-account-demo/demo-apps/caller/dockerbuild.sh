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

aws ecr get-login-password --region ap-southeast-1 --profile global2 | docker login --username AWS --password-stdin 996599195919.dkr.ecr.ap-southeast-1.amazonaws.com
docker build . -t x-ray-hello-demo:latest
docker tag x-ray-hello-demo:latest 996599195919.dkr.ecr.ap-southeast-1.amazonaws.com/x-ray-hello-demo:$DOCKER_IMAGE_VERSION
docker push 996599195919.dkr.ecr.ap-southeast-1.amazonaws.com/x-ray-hello-demo:$DOCKER_IMAGE_VERSION
