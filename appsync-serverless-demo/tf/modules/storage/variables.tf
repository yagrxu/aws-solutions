variable table_name {

}

variable counters_table_name {
  default = "counters"
}

variable billing_mode {
  default = "PAY_PER_REQUEST"
}

variable read_capacity {
  // optional for PPR
  default = null
}

variable write_capacity {
  // optional for PPR
  default = null
}

variable schema {
  default = <<EOF
input CreateDemoInput {
	id: String!
	origin: String!
	time: String
}

input DeleteDemoInput {
	id: String!
	origin: String!
}

type Demo {
	id: String!
	origin: String!
	time: String
}

type DemoConnection {
	items: [Demo]
	nextToken: String
}

type Mutation {
	createDemo(input: CreateDemoInput!): Demo
	updateDemo(input: UpdateDemoInput!): Demo
	deleteDemo(input: DeleteDemoInput!): Demo
}

type Query {
	getDemo(id: String!): Demo
	listDemos(filter: TableDemoFilterInput, limit: Int, nextToken: String): DemoConnection
}

type Subscription {
	onCreateDemo(id: String, origin: String, time: String): Demo
		@aws_subscribe(mutations: ["createDemo"])
	onUpdateDemo(id: String, origin: String, time: String): Demo
		@aws_subscribe(mutations: ["updateDemo"])
	onDeleteDemo(id: String, origin: String, time: String): Demo
		@aws_subscribe(mutations: ["deleteDemo"])
}

input TableBooleanFilterInput {
	ne: Boolean
	eq: Boolean
}

input TableDemoFilterInput {
	id: TableStringFilterInput
	origin: TableStringFilterInput
	time: TableStringFilterInput
}

input TableFloatFilterInput {
	ne: Float
	eq: Float
	le: Float
	lt: Float
	ge: Float
	gt: Float
	contains: Float
	notContains: Float
	between: [Float]
}

input TableIDFilterInput {
	ne: ID
	eq: ID
	le: ID
	lt: ID
	ge: ID
	gt: ID
	contains: ID
	notContains: ID
	between: [ID]
	beginsWith: ID
}

input TableIntFilterInput {
	ne: Int
	eq: Int
	le: Int
	lt: Int
	ge: Int
	gt: Int
	contains: Int
	notContains: Int
	between: [Int]
}

input TableStringFilterInput {
	ne: String
	eq: String
	le: String
	lt: String
	ge: String
	gt: String
	contains: String
	notContains: String
	between: [String]
	beginsWith: String
}

input UpdateDemoInput {
	id: String!
	origin: String!
	time: String
}
    EOF
}

variable request_template {
  default = <<EOF
{
  "version": "2017-02-28",
  "operation": "PutItem",
  "key": {
    "id": $util.dynamodb.toDynamoDBJson($ctx.args.input.id),
    "origin": $util.dynamodb.toDynamoDBJson($ctx.args.input.origin),
  },
  "attributeValues": {
    "time": $util.dynamodb.toDynamoDBJson($util.time.nowISO8601())
  },
  "condition": {
    "expression": "attribute_not_exists(#id) AND attribute_not_exists(#origin)",
    "expressionNames": {
      "#id": "id",
      "#origin": "origin",
    },
  },
}
EOF
}

variable response_template {
  default = <<EOF
$util.toJson($context.result)
EOF
}

variable get_template {
  default = <<EOF
{
  "version": "2017-02-28",
  "operation": "GetItem",
  "key": {
    "id": $util.dynamodb.toDynamoDBJson($ctx.args.id),
  }
}
EOF
}