const AWS = require('aws-sdk');

const dynamo = new AWS.DynamoDB.DocumentClient();
const cognitoIdentityServiceProvider = new AWS.CognitoIdentityServiceProvider();

const TABLE_NAME = 'mfsa-share'

const listCognitoUsers = () => {
    const params = {
      UserPoolId: process.env.USER_POOL_ID,
      AttributesToGet: ["sub"]
    };
  
    cognitoIdentityServiceProvider.listUsers(params, (err, data) => {
      if (err) {
        console.log(err, err.stack);
        callback(err)        // here is the error return
      } else {
        console.log(data);
        callback(null, data) // here is the success return
      }
    });
}

exports.handler = async (event, context) => {
    console.log('Received event:', JSON.stringify(event, null, 2));

    let body;
    let statusCode = '200';
    const headers = {
        'Content-Type': 'application/json',
    };

    try {
        switch (event.httpMethod) {
            case 'GET':
                body = await dynamo.get({
                    TableName: TABLE_NAME,
                    Key: { ResourceId: event.pathParameters.resource },
                }).promise();
                break;
            case 'PUT':
                body = await dynamo.update({
                    TableName: TABLE_NAME,
                    Key: { ResourceId: event.pathParameters.resource },
                    UpdateExpression: 'ADD IdentityIds :identityId',
                    ExpressionAttributeValues: { ':identityId': dynamo.createSet([event.body]) },
                }).promise();
                break;
            default:
                throw new Error(`Unsupported method "${event.httpMethod}"`);
        }
    }
    catch (err) {
        statusCode = '400';
        body = err.message;
    }
    finally {
        body = JSON.stringify(body);
    }

    return {
        statusCode,
        body,
        headers,
    };
};
