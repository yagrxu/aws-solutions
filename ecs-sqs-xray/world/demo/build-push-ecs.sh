function label() {
  echo
  echo
  echo "--------------------------------------"
  echo ":: $1"
  echo "--------------------------------------"
  echo
}

# shellcheck disable=SC2164
cd "$(dirname "$0")"
# shellcheck disable=SC2164
cd ../../tf
# shellcheck disable=SC2155
export CLUSTER_NAME=$(terraform output -raw cluster_name)

cd ../world/demo

mvn clean install

platform=$DOCKER_PLATFORM

# shellcheck disable=SC2155
export ACCOUNT=$(aws sts get-caller-identity | jq .Account -r)
export ECR_URL=${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com


if [ -z "$platform" ]
then
  platform="amd64"
fi


function buildDocker(){
  (
    # cd $rootDir/$1/$1-service || exit
    docker build --build-arg PLATFORM=$platform -t $ECR_URL/$CLUSTER_NAME-world:latest -f ./Dockerfile-ecs .
    docker push "$ECR_URL/$CLUSTER_NAME"-world:latest
  )
}

label "Login to ECR"
aws ecr get-login-password --region "${REGION}" | docker login --username AWS --password-stdin "$ECR_URL"

label "Package and push passport"
buildDocker

