const axios = require("axios");
const gql = require("graphql-tag");
const graphql = require("graphql");
const AWS = require("aws-sdk");
const path = require("path")
const { print } = graphql;

const docClient = new AWS.DynamoDB.DocumentClient({
  apiVersion: "2012-08-10",
  region: "eu-central-1",
});

exports.handler = function (event, context, callback) {
  console.log(event);
  processEvent(event, callback);
};

function processEvent(event, callback) {
  try {
    const requestInfo = event.requestContext;
    if (requestInfo.http.method == 'GET'){
      getRecord(requestInfo.http.path, callback);
    }
    else if (requestInfo.http.method == 'POST'){
      const bodyObj = JSON.parse(event.body);
      const action = bodyObj["action"];
      const url = bodyObj["url"];
      if (!action || !url) {
        returnError(
          500,
          "action must have both action and url properties in request body",
          callback
        );
      }
      if(bodyObj["action"] == 'add'){
        addRecord(event, callback);
      }
      else {
        returnError(500, "unknown action, accepted add only", callback);
      }
    }
    
  } catch (err) {
    console.log("catched error")
    returnError(500, callback(err), callback);
  }
}

function addRecord(event, callback) {
  getKey(event, callback);
}

async function updateUrl(id, event, callback) {
  console.log("update url");
  try {
    const createDemo = gql`
      mutation createDemo($createdemoinput: CreateDemoInput!) {
        createDemo(input: $createdemoinput) {
          id
          origin
          time
        }
      }
    `;
    const bodyObj = JSON.parse(event.body);
    const graphqlData = await axios({
      url: process.env.API_URL,
      method: "post",
      headers: {
        "x-api-key": process.env.API_KEY,
      },
      data: {
        query: print(createDemo),
        variables: {
          createdemoinput: {
            id: id,
            origin: bodyObj['url'],
          },
        },
      },
    });
    console.log("success added")
    const body = {
      url: 'https://' + process.env.DOMAIN_NAME + "/" + Buffer.from(id + "").toString("base64"),
      origin: bodyObj['url'],
      message: "successfully created!",
    };
    console.log("success callback");
    callback(null, {
      statusCode: 200,
      body: JSON.stringify(body),
      headers: {
        "Access-Control-Allow-Origin": "*",
      },
    });
  } catch (err) {
    returnError(500, err, callback)
  }
}

function getKey(event, callback) {
  docClient.get(
    {
      TableName: "counters",
      Key: {
        counterName: "demoCounter",
      },
      ConsistentRead: true,
    },
    function (err, data) {
      if (err) {
        returnError(500, err, callback);
      } else {
        updateValue(data, event, callback);
      }
    }
  );
}

function updateValue(data, event, callback) {
  console.log("update id");
  const currentValue = parseInt(data.Item.currentValue);
  const newValue = currentValue + 1;
  docClient.update(
    {
      TableName: "counters",
      ReturnValues: "UPDATED_NEW",
      ExpressionAttributeValues: {
        ":a": 1,
      },
      ExpressionAttributeNames: {
        "#v": "currentValue",
      },
      UpdateExpression: "SET #v = #v + :a",
      Key: {
        counterName: "demoCounter",
      },
    },
    function (err, data) {
      if (err) {
        returnError(500, err, callback);
      } else {
        console.log(JSON.stringify(data));
        updateUrl(data["Attributes"].currentValue, event, callback);
      }
    }
  );
}

function returnError(code, message, callback) {
  console.log("ERROR:" + message);
  callback(null, {
    statusCode: code,
    body: {
      message: message,
    },
    headers: {
      "Access-Control-Allow-Origin": "*",
    },
  });
}

async function getRecord(path, callback){
  console.log("get url");
  try {
    const getDemo = gql`
      query getDemo($id: String!) {
        getDemo(id: $id) {
          id
          origin
          time
        }
      }
    `;
    
    const pathBase64 = path.replace("/", "");
    let buff = new Buffer(pathBase64, 'base64');
    let id = buff.toString('ascii');
    console.log("search id" + id)
    const graphqlData = await axios({
      url: process.env.API_URL,
      method: "post",
      headers: {
        "x-api-key": process.env.API_KEY,
      },
      data: {
        query: print(getDemo),
        variables: {
          id: id
        },
      },
    });
    console.log(graphqlData.data.data.getDemo);
    const body = {
      origin: graphqlData.data.data.getDemo.origin,
      message: "successfully retrieved!",
    };
    callback(null, {
      statusCode: 301,
      body: JSON.stringify(body),
      headers: {
        "Location": graphqlData.data.data.getDemo.origin,
        "Access-Control-Allow-Origin": "*",
      },
    });
  } catch (err) {
    returnError(500, err, callback)
  }
}