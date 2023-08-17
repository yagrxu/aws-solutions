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
      echo "\$1 is empty, default version is v0.1"
      export DOCKER_IMAGE_VERSION="v0.1"
fi

region="ap-southeast-1"
if [ ! -z "$2" ]
then
      echo "\$2 is NOT empty - $2"
      region="$2"
else
      echo "default reguion is $region"
fi

docker_image_name="task-demo"

aws ecr get-login-password --region $region | docker login --username AWS --password-stdin 613477150601.dkr.ecr.$region.amazonaws.com
docker buildx build . --platform=linux/amd64 -t $docker_image_name:latest
docker tag $docker_image_name:latest 613477150601.dkr.ecr.$region.amazonaws.com/$docker_image_name:$DOCKER_IMAGE_VERSION
docker push 613477150601.dkr.ecr.$region.amazonaws.com/$docker_image_name:$DOCKER_IMAGE_VERSION
