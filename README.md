# tutorial_remote_mcp_auth

リモートMCPサーバの認証を試すための検証リポジトリ

## 構成

- `iac/` : Terraform によるインフラ定義（Cognito, AgentCore Gateway, Lambda, DynamoDB）
- `src/list_comments_handler.py` : Gateway ターゲットの実体。ユーザ（`sub`）に紐づくデータを DynamoDB から取得する
- `src/interceptor_handler.py` : Gateway のインターセプタ。リクエスト内の JWT から `sub` を取り出し、ツール呼び出しの引数に注入する

## 認証の流れ

1. クライアント（Claude Desktop / claude.ai など）が Cognito Hosted UI でログインし、JWT を取得
2. AgentCore Gateway が `CUSTOM_JWT` 設定に基づき JWT を検証
3. インターセプタ Lambda が JWT の `sub`（ユーザID）を取り出し、ツール呼び出しの引数に注入
4. ターゲット Lambda が `sub` をキーに DynamoDB を検索し、該当ユーザのデータのみを返す
