data "archive_file" "extract_sub" {
  type        = "zip"
  source_file = "${path.module}/../src/interceptor_handler.py"
  output_path = "${path.module}/build/interceptor_handler.zip"
}

resource "aws_iam_role" "interceptor" {
  name               = "${var.project_name}-interceptor-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "interceptor_basic_execution" {
  role       = aws_iam_role.interceptor.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "extract_sub" {
  function_name    = "${var.project_name}-extract-sub"
  role             = aws_iam_role.interceptor.arn
  handler          = "interceptor_handler.lambda_handler"
  runtime          = "python3.13"
  filename         = data.archive_file.extract_sub.output_path
  source_code_hash = data.archive_file.extract_sub.output_base64sha256
}
