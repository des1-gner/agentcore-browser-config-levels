#!/usr/bin/env bash
# Verify which AgentCore Browser configs are CreateBrowser (browser) level vs
# StartBrowserSession (session) level, by inspecting the live API parameters and
# submitting an unsupported parameter to observe the rejection.
#
# No account IDs are hard-coded. Set ROLE_ARN to a browser execution role in your
# own account before running the live create test. Region defaults to us-west-2.
set -uo pipefail
REGION="${AWS_REGION:-us-west-2}"
ROLE_ARN="${ROLE_ARN:-arn:aws:iam::<ACCOUNT_ID>:role/<BrowserExecutionRole>}"

echo "=== Parameters accepted by CreateBrowser (control plane) ==="
aws bedrock-agentcore-control create-browser help 2>/dev/null \
  | grep -oiE '\-\-(certificates|enterprise-policies|network-configuration|extensions|recording|browser-signing)' | sort -u

echo "=== Parameters accepted by StartBrowserSession (data plane) ==="
aws bedrock-agentcore start-browser-session help 2>/dev/null \
  | grep -oiE '\-\-(certificates|enterprise-policies|extensions|proxy-configuration|profile-configuration)' | sort -u

echo "=== Live proof: CreateBrowser rejects 'extensions' (session-only config) ==="
aws bedrock-agentcore-control create-browser \
  --cli-input-json "{\"name\":\"ext_probe\",\"executionRoleArn\":\"$ROLE_ARN\",\"networkConfiguration\":{\"networkMode\":\"PUBLIC\"},\"extensions\":[{\"s3Location\":{\"bucket\":\"x\",\"key\":\"y.zip\"}}]}" \
  --region "$REGION" 2>&1 | tail -3
