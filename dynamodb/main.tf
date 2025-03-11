resource "aws_dynamodb_table" "dynamodb_table" {
  name             = "tabla-bruno"
  hash_key         = "key"
  billing_mode     = "PAY_PER_REQUEST"

  attribute {
    name = "key"
    type = "S"
  }
}