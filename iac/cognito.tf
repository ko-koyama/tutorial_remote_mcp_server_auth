resource "aws_cognito_user_pool" "this" {
  name = "${var.project_name}-user-pool"
}

# Hosted UIのドメインプレフィックスはグローバルに一意である必要があるため、
# アカウントIDをサフィックスとして付与する
resource "aws_cognito_user_pool_domain" "this" {
  domain       = "${var.project_name}-${data.aws_caller_identity.current.account_id}"
  user_pool_id = aws_cognito_user_pool.this.id
}

# Claude Desktop / claude.ai用のApp Client（Authorization Code Grant、public client）
# client secretは発行しない。認可コード横取り対策はPKCE（Claude側がcode_challenge=S256を送信）に委ね、
# 実際のセキュリティ境界はCognito Hosted UIでのログイン（ユーザー名・パスワード）とする
resource "aws_cognito_user_pool_client" "claude_desktop" {
  name         = "${var.project_name}-claude-desktop-client"
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret = false

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid"]
  supported_identity_providers         = ["COGNITO"]

  callback_urls = [
    "https://claude.ai/api/mcp/auth_callback",
    "https://claude.com/api/mcp/auth_callback",
    # 手動での動作確認用（ブラウザのURLバーからcodeを取得するためのダミーコールバック）
    "http://localhost:8765/callback",
  ]

  prevent_user_existence_errors = "ENABLED"
}

# ログインテスト用のパスワードはterraformコマンド実行のたびに変わらないよう固定シードは使わず、
# ランダム生成してtfstateにのみ保持する
resource "random_password" "test_user_1" {
  length      = 16
  special     = true
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  min_special = 1
}

resource "aws_cognito_user" "test_user_1" {
  user_pool_id = aws_cognito_user_pool.this.id
  username     = "test-user-1"
  password     = random_password.test_user_1.result

  attributes = {
    email          = "test-user-1@example.com"
    email_verified = true
  }
}

resource "random_password" "test_user_2" {
  length      = 16
  special     = true
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  min_special = 1
}

resource "aws_cognito_user" "test_user_2" {
  user_pool_id = aws_cognito_user_pool.this.id
  username     = "test-user-2"
  password     = random_password.test_user_2.result

  attributes = {
    email          = "test-user-2@example.com"
    email_verified = true
  }
}
