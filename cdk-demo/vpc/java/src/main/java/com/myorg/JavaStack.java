package com.myorg;

import software.amazon.awscdk.services.ec2.*;
import software.constructs.Construct;
import software.amazon.awscdk.Stack;
import software.amazon.awscdk.StackProps;

import java.util.Arrays;
// import software.amazon.awscdk.Duration;
// import software.amazon.awscdk.services.sqs.Queue;

public class JavaStack extends Stack {
    public JavaStack(final Construct scope, final String id) {
        this(scope, id, null);
    }

    public JavaStack(final Construct scope, final String id, final StackProps props) {
        super(scope, id, props);


        // create a VPC with 2 subnets with 1 AZ each
        final Vpc vpc = new Vpc(this, "demo-vpc", VpcProps.builder()
                .maxAzs(3)
                .natGateways(1)
                .subnetConfiguration(Arrays.asList(
                         SubnetConfiguration.builder()
                                .cidrMask(24)
                                .name("public")
                                .subnetType(SubnetType.PUBLIC)
                                .build(),
                        SubnetConfiguration.builder()
                                .cidrMask(24)
                                .name("private")
                                .subnetType(SubnetType.PRIVATE_WITH_EGRESS)
                                .build()))
                 .build());
        // create a VPC with 3 AZs,  0 NAT gateway and 1 public subnets
        final Vpc newVpc = Vpc.Builder.create(this, "another-demo-vpc")
                .maxAzs(3)
                .natGateways(0)
                .subnetConfiguration(Arrays.asList(
                        SubnetConfiguration.builder()
                                .cidrMask(24)
                                .name("public")
                                .subnetType(SubnetType.PUBLIC)
                                .build())
                )
                .build();
    }

}
