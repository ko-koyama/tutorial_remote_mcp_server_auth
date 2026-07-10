import base64
import json


def lambda_handler(event, context):
    gateway_request = event["mcp"]["gatewayRequest"]
    body = gateway_request["body"]

    if body.get("method") == "tools/call":
        headers = {k.lower(): v for k, v in gateway_request["headers"].items()}
        token = headers["authorization"].removeprefix("Bearer ")

        # GatewayがCUSTOM_JWTで既に署名検証済みのため、ここでは再検証せずペイロードをデコードするだけでよい
        payload = token.split(".")[1]
        payload += "=" * (-len(payload) % 4)
        claims = json.loads(base64.urlsafe_b64decode(payload))

        body["params"]["arguments"]["sub"] = claims["sub"]

    return {
        "interceptorOutputVersion": "1.0",
        "mcp": {
            "transformedGatewayRequest": {
                "body": body,
            }
        },
    }
