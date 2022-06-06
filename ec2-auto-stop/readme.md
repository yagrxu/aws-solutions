# Basic Cost Saving for EC2 On-Demand Instances

I have observed that some customers are using EC2 instances in a more entry level manner.

When I am talking about "entry level", I am refering to the customers that are simply launch a EC2 instance with OnDemand paying model withoutt trying to save cost from various possibilities.

To further elaborate what I would like to achieve in this demo, I simply put a list of actions that a customer would consider for cost saving.

1. For long running instance, switch the billing model from OnDemand to Reserved Instance.
2. For jobs that can be interrupted, switch from ON-Demand to Spot Intance.
3. For function liked workload, try to adopt serverless architectures.
4. Stop the infrequently used instances during the idle period.


## About the Demo

### Idea

For the list of actions above. The first action is more achievable on the customer side without any technical investment.

The second and third actions require architecture upgrade which can be a heavy technical investment.

The last one is easy to understand and to automate as well. Therefore I would like to create a simple demo for customers who are seaking for cost saving without having DevOps resources yet.

### What the Demo achieves

1. This demo will deploy a complete stack via terraform, including a eventbridge rule, a lambda function, a exec role for the lambda function and its min policies required.
2. The event bridge rule will capture the instance status change and trigger the lambda execution.
3. If the instance is tagged with a pre-defined value e.g. default is "StopMonitor=yes", then lambda funtion will maintain an alarm with CPUUtilization monitoring on 20% level for this instance. If over 3 checkpoints the instance's max CPU usage is lower than 20%, the alarm will stop the instance. When the instance is stopped, the lambda will also recycle the alarm for the instance.

The calling chain can be reflected as below.

1. Start instance -> Instance Status Change -> EventBridge Rule -> Lambda -> Create CloudWatch Alarm
2. CPU usage low alarm -> Stop instance -> Instance Status Change -> EventBridge Rule -> Lambda -> Delete CloudWatch Alarm (send email as notification as well)

### Extended Scenarios

1. The same monitoring concept can be used for wipe out test resources in test account. This has been widely used in many cloud provider product teams
2. Many parameters in this demo can be tweaked to adopt to customer's real scenarios. e.g. Stop instance/Hibernate isntance/Terminate instance, CPU Usage/Memory Usage/IOPS, EC2 instances/Kubernetes Clusters/EMR Clusters/RDS (which can be setup or restored easily). 
3. It can be considered as DevOps automation entry point.

## Prerequisites

1. Terraform installed for stack deployment
https://learn.hashicorp.com/tutorials/terraform/install-cli

2. A user with proper privilleges is prepared with AK and SK for terraform

3. A user with proper privilleges is prepared with AK and SK for lambda execution (create/delete CloudWatch alarm - PutMetricAlarm/DeleteAlarms, check instance tags - DescribeInstances)
This can be further improved with automation included in terraform.

## Run through the demo

1. Setup a "admin" user's AK SK in the environment as AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and maintain an enrivonment value for the to be deployed region e.g. `export AWS_DEFAULT_REGION=ap-southeast-1` for Singapore.

``` bash
# prepare admin AK/SK
export AWS_ACCESS_KEY_ID=AdminAK
export AWS_SECRET_ACCESS_KEY=AdminSK
export AWS_DEFAULT_REGION=ap-southeast-1

```

2. Prepare a "user" with PutMetricAlarm, DeleteAlarms, and DescribeInstances privillege and set the AK/SK of the user in environment.

``` bash
# prepare lambda AK/SK
export TF_VAR_access_key_id="User AK"
export TF_VAR_secret_access_key="User SK"
```

3. Package the lambda file, setup Tag key/value and deploy the terraform stack as below

``` bash

zip ./tf/archive.zip ./index.py

export TF_VAR_ec2_tag_key=StopMonitor
export TF_VAR_ec2_tag_value=yes

cd tf
terraform init
terraform apply --auto-approve

```

4. Launch 2 instances (A and B), A with tag "StopMonitor=yes" while B without this tag.

5. Verify Result

- After the instance launched, the status will be changed to "running".

- Lambda will be triggered, create a metric alarm for A, and do nothing for B.

- Leave A as it is without running any process and the max CPU usage will be constantly lower than 20%. after 15 minutes, alarm will be triggered and the instance A will be stopped.

- The alarm will be deleted as well after the instance A is stopped.

