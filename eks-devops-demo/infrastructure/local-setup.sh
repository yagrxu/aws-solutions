#! /bin/bash
response=$(aws eks update-kubeconfig --name $1 --kubeconfig ~/.kube/$2 --alias $2 --region $3)
export KUBECONFIG=~/.kube/$2
if [ $? != 0 ]
then
    result="{\"info\": \"setup\", \"response\": \"$response\"}"
    echo $result
    exit 1
fi
    result="{\"info\": \"setup\", \"response\": \"$2\"}"
    echo $result