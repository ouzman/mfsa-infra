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
                const params = {
                    TableName: TABLE_NAME,
                    Key: { ResourceId : event.pathParameters.resource },
                };
                body = await dynamo.get(params).promise();
                break;
            case 'PUT':
                const params = {
                    TableName: TABLE_NAME,
                    Key: { HashKey : 'ResourceId' },
                    UpdateExpression: 'ADD IdentityIds :identityId',
                    ExpressionAttributeValues: {
                        ':identityId' : [event.body],
                    },
                };

                body = await dynamo.update(params).promise();
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
