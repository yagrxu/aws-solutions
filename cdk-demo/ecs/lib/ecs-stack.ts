import { Construct } from 'constructs';
import * as cdk from 'aws-cdk-lib';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as ecs from 'aws-cdk-lib/aws-ecs';
import * as ecr from 'aws-cdk-lib/aws-ecr';
import * as eks from 'aws-cdk-lib/aws-eks';
import * as iam from 'aws-cdk-lib/aws-iam';



export class EcsStack extends cdk.Stack {
  constructor( scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Create a VPC
    const vpc = new ec2.Vpc(this, 'MyVpc', {
      maxAzs: 3, // Specify the desired number of Availability Zones
    });

    this.cats = new ecr.Repository(this, 'cats', {
      repositoryName: 'cats',
    });

    this.createEcs(this, vpc);

    const eks_cluster = new eks.Cluster(this, 'eks-cluster', {
      version: eks.KubernetesVersion.V1_27,
      defaultCapacity: 0,
      vpc: vpc,
    });

    eks_cluster.addNodegroupCapacity('custom-node-group', {
      instanceTypes: [new ec2.InstanceType('m5.large')],
      minSize: 2,
      diskSize: 100,
      amiType: eks.NodegroupAmiType.AL2_X86_64,
    });

    new ecr.Repository(this, 'dogs', {
      repositoryName: 'dogs',
    });
  }
  cats: ecr.Repository
  createEcs(scope: Construct, vpc: ec2.Vpc){

    const cluster = new ecs.Cluster(scope, 'MyEcsCluster', {
      vpc,
    });
    cluster.addCapacity('DefaultAutoScalingGroup', {
      instanceType: ec2.InstanceType.of(
        ec2.InstanceClass.T3,
        ec2.InstanceSize.LARGE
      ),
      minCapacity: 2,
      maxCapacity: 5, // Specify the desired number of instances
    });
  //   const taskDefinition = new ecs.Ec2TaskDefinition(scope, "cats-service");
  //   taskDefinition.addContainer("cats", {
  //     image: ecs.ContainerImage.fromRegistry(this.cats.repositoryUri),
  //     memoryLimitMiB: 256,
  //   });
  //   const executionRolePolicy =  new iam.PolicyStatement({
  //     effect: iam.Effect.ALLOW,
  //     resources: ['*'],
  //     actions: [
  //               "ecr:GetAuthorizationToken",
  //               "ecr:BatchCheckLayerAvailability",
  //               "ecr:GetDownloadUrlForLayer",
  //               "ecr:BatchGetImage",
  //               "logs:CreateLogStream",
  //               "logs:PutLogEvents"
  //           ]
  //   });
  // }
}