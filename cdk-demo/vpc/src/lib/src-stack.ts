import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';

// import * as sqs from 'aws-cdk-lib/aws-sqs';

export class SrcStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // The code that defines your stack goes here

    // example resource
    // const queue = new sqs.Queue(this, 'SrcQueue', {
    //   visibilityTimeout: cdk.Duration.seconds(300)
    // });
    // create a new vpc 
    new cdk.aws_ec2.Vpc(this, 'Vpc', {
      natGateways: 0,
      subnetConfiguration: [
        // create a subnet
        {
          cidrMask: 24,
          name: 'public',
          subnetType: cdk.aws_ec2.SubnetType.PUBLIC
        }
      ]

    });
  }
}
