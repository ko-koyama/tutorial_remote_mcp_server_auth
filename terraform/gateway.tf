data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "gateway_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["bedrock-agentcore.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_iam_role" "gateway" {
  name               = "${var.project_name}-gateway-role"
  assume_role_policy = data.aws_iam_policy_document.gateway_assume.json
}

data "aws_iam_policy_document" "gateway_invoke_lambda" {
  statement {
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.list_comments.arn]
  }
}

resource "aws_iam_role_policy" "gateway_invoke_lambda" {
  name   = "${var.project_name}-gateway-invoke-lambda"
  role   = aws_iam_role.gateway.id
  policy = data.aws_iam_policy_document.gateway_invoke_lambda.json
}

data "aws_iam_policy_document" "gateway_invoke_interceptor" {
  statement {
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.extract_sub.arn]
  }
}

resource "aws_iam_role_policy" "gateway_invoke_interceptor" {
  name   = "${var.project_name}-gateway-invoke-interceptor"
  role   = aws_iam_role.gateway.id
  policy = data.aws_iam_policy_document.gateway_invoke_interceptor.json
}

resource "aws_bedrockagentcore_gateway" "this" {
  name     = var.project_name
  role_arn = aws_iam_role.gateway.arn

  authorizer_type = "CUSTOM_JWT"
  protocol_type   = "MCP"

  authorizer_configuration {
    custom_jwt_authorizer {
      discovery_url   = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.this.id}/.well-known/openid-configuration"
      allowed_clients = [aws_cognito_user_pool_client.claude_desktop.id]
    }
  }

  # tools/call実行前にJWTのsubを取り出し、target Lambdaへの引数(arguments.sub)に注入する
  interceptor_configuration {
    interception_points = ["REQUEST"]

    input_configuration {
      pass_request_headers = true
    }

    interceptor {
      lambda {
        arn = aws_lambda_function.extract_sub.arn
      }
    }
  }
}

resource "aws_bedrockagentcore_gateway_target" "list_comments" {
  name               = "list-comments"
  gateway_identifier = aws_bedrockagentcore_gateway.this.gateway_id
  description        = "サンプルテーブルから上位5件のコメントを取得するLambdaターゲット"

  credential_provider_configuration {
    gateway_iam_role {}
  }

  target_configuration {
    mcp {
      lambda {
        lambda_arn = aws_lambda_function.list_comments.arn

        tool_schema {
          inline_payload {
            name        = "list_comments"
            description = "リクエストしたユーザー自身のコメントを最大5件取得する"

            input_schema {
              type = "object"
            }

            output_schema {
              type = "object"

              property {
                name     = "items"
                type     = "array"
                required = true

                items {
                  type = "object"

                  property {
                    name     = "sub"
                    type     = "string"
                    required = true
                  }

                  property {
                    name     = "comment"
                    type     = "string"
                    required = true
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
