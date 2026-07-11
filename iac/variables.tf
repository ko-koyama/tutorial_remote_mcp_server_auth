variable "project_name" {
  description = "リソース名のプレフィックスとして使用する名前"
  type        = string
  default     = "tutorial-remote-mcp-server-auth"
}

variable "aws_region" {
  description = "デプロイ先のAWSリージョン"
  type        = string
  default     = "us-east-1"
}
