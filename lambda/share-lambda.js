const AWS = require('aws-sdk');

const dynamo = new AWS.DynamoDB.DocumentClient();

const TABLE_NAME = 'mfsa-share'

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
