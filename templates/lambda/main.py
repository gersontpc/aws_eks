import boto3

def handler (event,_):
    printf(event)
    client = boto3.client ('ec2')
    response = client.create_tags(
        Resources=event.get("subnet_ids"),
        Tags=[
            {
                'Key': "karpenter.sh/discovery",
                'Value': '${var.cluster_name}'
            },
        ]
    )
print(response)