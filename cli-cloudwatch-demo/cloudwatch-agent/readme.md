# How to Enable CloudWatch Agent for EC2 Metrics

## Installing from SSM
https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/installing-cloudwatch-agent-ssm.html

## Install and Start
https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Agent-on-EC2-Instance-fleet.html

## Adopt Configurations
https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Agent-Configuration-File-Details.html#CloudWatch-Agent-Configuration-File-Complete-Example

## Key Points

1. aggregation dimension definition in agent config file is important

    ``` json
    {
        "aggregation_dimensions" : [["ImageId"], ["InstanceId", "InstanceType"],["InstanceId"], []]
    }  
    ```

    If `["InstanceId"]` is not defined there, you can not query the metrics by only using InstanceId
