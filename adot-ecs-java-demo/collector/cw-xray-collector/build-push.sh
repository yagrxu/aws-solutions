function label() {
  echo
  echo
  echo "--------------------------------------"
  echo ":: $1"
  echo "--------------------------------------"
  echo
}

ecrUri=$1
version=$2
platform=$DOCKER_PLATFORM

if [ -z "$ecrUri" ]
then
      echo "\ecrUri is empty."
      exit
fi

if [ -z "$version" ]
then
  version="1.0.0"
fi

if [ -z "$platform" ]
then
  platform="amd64"
fi

# 320236118172.dkr.ecr.us-east-1.amazonaws.com

function buildDocker(){
  (
    rootDir=${PWD}
    # cd $rootDir/$1/$1-service || exit
    docker build --build-arg PLATFORM=$platform -t $ecrUri/adot-ecs-collector:$version -f ./Dockerfile .
    docker push $ecrUri/adot-ecs-collector:$version
  )
}

label "Login to ECR"
aws ecr get-login-password | docker login --username AWS --password-stdin $ecrUri

label "Package and push passport"
buildDocker

