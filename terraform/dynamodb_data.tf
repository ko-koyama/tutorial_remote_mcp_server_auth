# subはリテラルで固定せず、実際に作成されたCognitoユーザーのsub属性を参照する。
# こうしておくことでユーザープールを作り直してsubが変わっても、テストデータが追従する。
resource "aws_dynamodb_table_item" "test_user_1_comments" {
  count      = 5
  table_name = aws_dynamodb_table.comments.name
  hash_key   = aws_dynamodb_table.comments.hash_key
  range_key  = aws_dynamodb_table.comments.range_key

  item = jsonencode({
    sub     = { S = aws_cognito_user.test_user_1.sub }
    comment = { S = "test_user_1の${count.index + 1}つ目のコメント" }
  })
}

resource "aws_dynamodb_table_item" "test_user_2_comments" {
  count      = 5
  table_name = aws_dynamodb_table.comments.name
  hash_key   = aws_dynamodb_table.comments.hash_key
  range_key  = aws_dynamodb_table.comments.range_key

  item = jsonencode({
    sub     = { S = aws_cognito_user.test_user_2.sub }
    comment = { S = "test_user_2の${count.index + 1}つ目のコメント" }
  })
}
