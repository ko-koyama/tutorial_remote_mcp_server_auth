output "gateway_url" {
  description = "MCPクライアントが接続するGatewayのURL"
  value       = aws_bedrockagentcore_gateway.this.gateway_url
}

output "gateway_id" {
  value = aws_bedrockagentcore_gateway.this.gateway_id
}

output "lambda_function_name" {
  value = aws_lambda_function.list_comments.function_name
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.comments.name
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.this.id
}

output "cognito_app_client_id" {
  description = "Claude Desktop等に手動設定するOAuth Client ID"
  value       = aws_cognito_user_pool_client.claude_desktop.id
}

output "cognito_hosted_ui_authorize_url" {
  description = "手動動作確認用: ブラウザで開いてログインし、リダイレクト先URLのcodeパラメータを取得する"
  value       = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${var.aws_region}.amazoncognito.com/oauth2/authorize?response_type=code&client_id=${aws_cognito_user_pool_client.claude_desktop.id}&redirect_uri=http://localhost:8765/callback&scope=openid"
}

output "cognito_token_endpoint" {
  description = "認可コードをトークンに交換するエンドポイント"
  value       = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${var.aws_region}.amazoncognito.com/oauth2/token"
}

output "test_user_1_username" {
  value = aws_cognito_user.test_user_1.username
}

output "test_user_1_password" {
  value     = random_password.test_user_1.result
  sensitive = true
}

output "test_user_2_username" {
  value = aws_cognito_user.test_user_2.username
}

output "test_user_2_password" {
  value     = random_password.test_user_2.result
  sensitive = true
}
