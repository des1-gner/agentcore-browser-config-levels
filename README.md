# AgentCore Browser: which configs are browser-level vs session-level

Verifies, against the live Amazon Bedrock AgentCore APIs, where each custom-browser
configuration actually belongs: the **CreateBrowser** API (browser level, applies to
all sessions) or the **StartBrowserSession** API (session level).

## TL;DR (verified)

| Configuration | Level |
|---|---|
| VPC (`networkConfiguration`) | CreateBrowser (browser) |
| Enterprise policies | **Both** CreateBrowser and StartBrowserSession |
| Custom root certificates | **Both** CreateBrowser and StartBrowserSession |
| Browser extensions | **StartBrowserSession only** (session) |
| Proxies | StartBrowserSession (session) |
| Browser profiles | StartBrowserSession (session) |

The two that trip people up: **extensions are session-level only** (CreateBrowser has
no `extensions` parameter), and **enterprise policies and custom root certificates can
be set at either level** (both parameters exist on CreateBrowser and StartBrowserSession).

## How it's verified

1. Inspect the parameters each API accepts (`aws ... help`).
2. Live proof: submit `extensions` to CreateBrowser and observe the rejection, the
   service returns its exact accepted-parameter list, and `extensions` is not in it.

```bash
ROLE_ARN="arn:aws:iam::<your-account>:role/<BrowserExecutionRole>" \
AWS_REGION=us-west-2 ./verify_browser_config_levels.sh
```

See `sample-output.txt` for desensitised output, including the verbatim CreateBrowser
rejection message.

## References

- Browser extensions (session creation time): https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/browser-extensions.html
- Enterprise policies (both levels): https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/browser-enterprise-policies.html
- Custom root CA certificates (both levels): https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/browser-root-ca-certificates.html
- CreateBrowser networkConfiguration (VPC): https://docs.aws.amazon.com/bedrock-agentcore-control/latest/APIReference/API_CreateBrowser.html

## Notes

- No account IDs, role ARNs, security-group or subnet IDs are committed; replace the
  `<PLACEHOLDERS>` with your own.
