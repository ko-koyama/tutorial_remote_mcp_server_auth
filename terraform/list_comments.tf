data "archive_file" "list_comments" {
  type        = "zip"
  source_file = "${path.module}/../src/list_comments_handler.py"
  output_path = "${path.module}/build/list_comments_handler.zip"
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "list_comments" {
  name               = "${var.project_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "list_comments_basic_execution" {
  role       = aws_iam_role.list_comments.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "list_comments_dynamodb_read" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:Query"]
    resources = [aws_dynamodb_table.comments.arn]
  }
}

resource "aws_iam_role_policy" "list_comments_dynamodb_read" {
  name   = "${var.project_name}-lambda-dynamodb-read"
  role   = aws_iam_role.list_comments.id
  policy = data.aws_iam_policy_document.list_comments_dynamodb_read.json
}

resource "aws_lambda_function" "list_comments" {
  function_name    = "${var.project_name}-list-comments"
  role             = aws_iam_role.list_comments.arn
  handler          = "list_comments_handler.lambda_handler"
  runtime          = "python3.13"
  filename         = data.archive_file.list_comments.output_path
  source_code_hash = data.archive_file.list_comments.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.comments.name
    }
  }
}
