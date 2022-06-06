import json
import os
import boto3

def lambda_handler(event, context):
    print(event)
    instance_id = event["detail"]['instance-id']
    state = event["detail"]['state']
    region = event["region"]

    ec2_client = create_ec2_client(region)
    if (state != 'running' and state != 'stopped') or not is_instance_under_control(ec2_client, instance_id):
        print('nothing to do')
        return
    
    client = create_cw_client(region)
    if state == 'running':
        # create the alarm
        create_cw_alarm(client, instance_id)
    if state == 'stopped':
        # delete alarm
        delete_cw_alarm(client, instance_id)
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }

def create_cw_client(region):
    return boto3.client('cloudwatch', 
        aws_access_key_id=os.getenv('GLOBAL_AWS_ACCESS_KEY_ID'),
        aws_secret_access_key=os.getenv('GLOBAL_AWS_SECRET_ACCESS_KEY'),
        region_name=region)

def create_ec2_client(region):
    return boto3.client('ec2', 
        aws_access_key_id=os.getenv('GLOBAL_AWS_ACCESS_KEY_ID'),
        aws_secret_access_key=os.getenv('GLOBAL_AWS_SECRET_ACCESS_KEY'),
        region_name=region)

def is_instance_under_control(client, instance_id):
    response = client.describe_instances(
        InstanceIds=[
            instance_id,
        ]
    )
    
    tags = response['Reservations'][0]['Instances'][0]['Tags']

    for tag in tags:
        if tag["Key"] == 'StopMonitor' and tag["Value"] == 'yes':
            return True
    return False

def create_cw_alarm(client, instance_id):
    response = client.put_metric_alarm(
        AlarmName='cpu-usage-monitor-' + instance_id,
        AlarmDescription='',
        ActionsEnabled=True,
        AlarmActions=[
            'arn:aws:sns:ap-southeast-1:613477150601:Instance_Low_Usage',
            'arn:aws:automate:ap-southeast-1:ec2:stop'
        ],
        MetricName='CPUUtilization',
        Dimensions=[
            {
                'Name': 'InstanceId',
                'Value': instance_id
            },
        ],
        Namespace='AWS/EC2',
        Statistic='Maximum',
        Period=300,
        EvaluationPeriods=3,
        DatapointsToAlarm=3,
        Threshold=20.0,
        ComparisonOperator='LessThanThreshold',
        TreatMissingData='notBreaching'

    )

def delete_cw_alarm(client, instance_id):
    client.delete_alarms(
        AlarmNames=[
            'cpu-usage-monitor-' + instance_id,
        ]
    )