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

const getUserSubByEmail = async ({ email }) => {
    const { users } = await listCognitoUsers();
    console.log({ users });
    const user = users
        .map(u => u.Attributes)
        .map(userAttr => userAttr.reduce((acc, it) => ({ ...acc, [it.Name]: it.Value }), {}))
        .find(u => u.email.toLowerCase() === email.toLowerCase());

    if (user) {
        return user.sub
    } else {
        throw new Error("Email does not match with any user")
    }
}

const addIdentityToResource = async ({ resource, identity, owner }) => {
    return dynamo.update({
        TableName: TABLE_NAME,
        Key: { "ResourceId": resource },
        UpdateExpression: 'SET #OWN=:ownerId ADD #IDS :identityId',
        ExpressionAttributeNames: {
            '#OWN': 'OwnerId',
            '#IDS': 'IdentityIds'
        },
        ExpressionAttributeValues: {
            ':ownerId': owner,
            ':identityId': dynamo.createSet([identity])
        },
    }).promise();
}

const listResourceIdsByIdentity = async ({ identity }) => {
    const params = {
        TableName: TABLE_NAME,
        FilterExpression: "contains (IdentityIds, :identity)",
        ExpressionAttributeValues : { ':identity' : identity }
    };
    const resources = await dynamo.scan(params).promise();

    return resources.Items;
}

const generateResourceResponse = ({ resource }) => {
    return {
        nativeKey: `protected/eu-west-1:${resource.OwnerId}/${resource.ResourceId}`,
        key: resource.ResourceId,
        owner: resource.OwnerId
    }
}

const deleteResource = async ({ resource }) => {
    const params = {
        TableName: TABLE_NAME,
        Key: { "ResourceId": resource }
    };
    return await dynamo.delete(params).promise();
}

exports.handler = async (event, context) => {
    console.log('Received event:', JSON.stringify(event, null, 2));

    let body;
    let statusCode = '200';
    const headers = {
        'Content-Type': 'application/json',
    };

    try {
        if (event.httpMethod === 'GET') {
            const list = await listResourceIdsByIdentity({ identity: event.requestContext.authorizer.claims.sub })
            body = list.map(listItem => generateResourceResponse({ resource: listItem}))
        } else if (event.httpMethod === 'DELETE') {
            body = await deleteResource({ resource: event.pathParameters.resource })
        } else if (event.httpMethod == 'PUT') {
            const params = { 
                identity: await getUserSubByEmail({ email: event.body }),
                resource: event.pathParameters.resource,
                owner: event.requestContext.authorizer.claims.sub
            }
            body = await addIdentityToResource(params);
        } else {
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
        console.log(body);
    }

    return {
        statusCode,
        body,
        headers,
    };
};
