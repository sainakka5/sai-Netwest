import json
import boto3

def lambda_handler(event, context):
    # Log the event details to CloudWatch Logs
    print("Received event: " + json.dumps(event))

    # Example: Logging the object key
    for record in event['Records']:
        print("Bucket: " + record['s3']['bucket']['name'])
        print("Object key: " + record['s3']['object']['key'])

    return {
        'statusCode': 200,
        'body': json.dumps('Event logged successfully')
    }
