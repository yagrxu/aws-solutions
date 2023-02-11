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
      export ROLE_NAME="$1"
else
      echo "\$1 is empty"
      export ROLE_NAME="cloud-watch-agent-demo"
fi


aws iam detach-role-policy --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy --role-name $ROLE_NAME
aws iam detach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore --role-name $ROLE_NAME
aws iam delete-role --role-name $ROLE_NAME
