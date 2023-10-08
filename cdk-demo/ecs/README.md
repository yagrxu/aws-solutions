# Welcome to your CDK TypeScript project

This is a blank project for CDK development with TypeScript.

The `cdk.json` file tells the CDK Toolkit how to execute your app.

## Useful commands

* `npm run build`   compile typescript to js
* `npm run watch`   watch for changes and compile
* `npm run test`    perform the jest unit tests
* `cdk deploy`      deploy this stack to your default AWS account/region
* `cdk diff`        compare deployed stack with current state
* `cdk synth`       emits the synthesized CloudFormation template

## Container Insights

``` shell
# account level
aws ecs put-account-setting --name "containerInsights" --value "enabled"

# cluster level
aws ecs update-cluster-settings --cluster EcsStack-MyEcsCluster989E66E0-NCuyzzigkARj --settings name=containerInsights,value=enabled
```

```shell
aws ecs update-cluster-settings --cluster myCICluster --settings name=containerInsights,value=disabled
```