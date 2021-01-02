const util = require('util')
const AWS = require('aws-sdk');

const dynamo = new AWS.DynamoDB.DocumentClient();
const cognitoIdentityServiceProvider = new AWS.CognitoIdentityServiceProvider();

const TABLE_NAME = 'mfsa-share'

const listCognitoUsers = () => {
    const params = {
        UserPoolId: process.env.USER_POOL_ID,
        AttributesToGet: ['sub', 'email']
    };

    return new Promise((resolve, reject) => {
        cognitoIdentityServiceProvider.listUsers(params, (err, data) => {
            if (err) {
                reject(err) // here is the error return
            }
            else {
                resolve({ users: data.Users }) // here is the success return
            }
        });
    });
}

const getUserSubByEmail = async(email) => {
    const { users } = await listCognitoUsers();
    console.log({ users });
    return users
        .map(u => u.Attributes)
        .map(userAttr => userAttr.reduce((acc, it) => ({ ...acc, [it.Name]: it.Value }), {}))
        .find(u => u.email.toLowerCase() === email.toLowerCase())
        .sub;
}

exports.handler = async(event, context) => {
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
                let identitySub = await getUserSubByEmail(event.body);
                console.log({ identitySub })
                
                body = await dynamo.update({
                    TableName: TABLE_NAME,
                    Key: { ResourceId: event.pathParameters.resource },
                    UpdateExpression: 'ADD IdentityIds :identityId',
                    ExpressionAttributeValues: { ':identityId': dynamo.createSet([identitySub]) },
                }).promise();
                
                break;
            default:
                throw new Error(`Unsupported method "${event.httpMethod}"`);
        }
    }
    catch (err) {
        console.log(util.inspect(err, { showHidden: false, depth: null }))
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
