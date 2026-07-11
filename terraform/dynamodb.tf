resource "aws_dynamodb_table" "comments" {
  name         = "${var.project_name}-comments"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "sub"
  range_key    = "comment"

  attribute {
    name = "sub"
    type = "S"
  }

  attribute {
    name = "comment"
    type = "S"
  }
}
