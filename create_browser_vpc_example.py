#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = ["boto3"]
# ///
"""Create an AgentCore Browser with VPC access. Fill in your own role/SG/subnet.
No account IDs are hard-coded; replace the <PLACEHOLDERS>."""
import os, boto3

cp = boto3.client("bedrock-agentcore-control", region_name=os.environ.get("AWS_REGION", "us-west-2"))

resp = cp.create_browser(
    name="BrowserVPCExample",
    description="Browser with VPC access",
    executionRoleArn="arn:aws:iam::<ACCOUNT_ID>:role/<BrowserExecutionRole>",
    networkConfiguration={
        "networkMode": "VPC",
        "vpcConfig": {
            "securityGroups": ["<sg-id>"],
            "subnets": ["<subnet-id>"],
        },
    },
)
print("BrowserId:", resp.get("browserId"))
