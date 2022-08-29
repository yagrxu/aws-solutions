# Run a tiny URL solution on AWS

Key words: #IaC #Infrastructure as Code

## Purpose

1. Demonstrate how a serverless solution with automated CI/CD on AWS look like

2. Testing cross service functionalities to bridge the gaap on customer side

## How to Run

### Prerequisites

1. Register a valid domain
 (**yagrxu.me** will be used for the demo)

2. Create a hosted zone for the registered domain name manually (This is should not be the part of CI/CD as long as solution does not require many domain names or domain names rotation)

3. apply ACM certificates for required subdomains manually in advance. (This cannot be automated as pending validation might take days to finish)

### Running it via CI/CD Tool

- the travis-ci.yml is already in the root of the repo
- it is configured to be automatically triggered on push/merge event on master brach

### Running it Locally

```bash

# the deployment can be done by running the command below directly in a local setup
source local.bash # prepare env variables
sh ./scripts/install.sh # run install commands

#start local blog server
brew install hugo
cd ./s3/demo
hugo server -D

# open browser on localhost:1313
```
**note!**: ShortUrl link is not working right now as Route 53 newly create record cannot be resolved by NS properly. please replace it with API GW direct access link https://woe7di0od8.execute-api.eu-central-1.amazonaws.com/{Key}

## How to further contribute

1. If any question, please directly create issues to clarify
2. create a PR to submit changes/improvements.

## Scope and Limitations

### Services scopes

- S3: static website
- APIGW: exposing Rest API for lambda functions
- Lambda: functions
- AppSync: exposing Storage in GraphQL format
- DynamoDB: used as KV Storage.

### Technologies

- Terraform
- AWS
- nodejs

### Limitations

- Route53 and ACM full automation (This can be resolved by using K8s cert-manager with external-dns)

- Logging and Monitoring (As time limits, Logging and Monitoring are not in the demo scope)

- Local Test (e.g. using LocalStack) - As time limits this is not in the demo scope but in next step consideration for improving the development efficiency.
