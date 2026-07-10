import os

import boto3
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])


def lambda_handler(event, context):
    response = table.query(KeyConditionExpression=Key("sub").eq(event["sub"]), Limit=5)
    return {"items": response.get("Items", [])}
