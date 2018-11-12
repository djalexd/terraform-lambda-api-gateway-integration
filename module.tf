
provider "aws" {}

variable "rest_api_id" {}
variable "resource_id" {}

variable "http_method" {}

variable "authorizer" {
  default = "NONE"
}

variable "use_api_key" {
  default = "false"
}

variable "region" {}

variable "lambda_function" {}

variable "lambda_role" {}

variable "response_models" {
  default = {
    "application/json" = "Empty"
  }
}

variable "response_templates" {
  default = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_method" "method" {
  rest_api_id      = "${var.rest_api_id}"
  resource_id      = "${var.resource_id}"
  http_method      = "${var.http_method}"
  authorization    = "${var.authorizer == "NONE" ? "NONE" : "CUSTOM"}"
  authorizer_id    = "${var.authorizer == "NONE" ? "" : var.authorizer}"
  api_key_required = "${var.use_api_key}"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = "${var.rest_api_id}"
  resource_id             = "${var.resource_id}"
  type                    = "AWS_PROXY"
  http_method             = "${aws_api_gateway_method.method.http_method}"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_function}/invocations"
  credentials             = "${var.lambda_role}"
}

resource "aws_api_gateway_method_response" "response" {
  rest_api_id     = "${var.rest_api_id}"
  resource_id     = "${var.resource_id}"
  http_method     = "${aws_api_gateway_method.method.http_method}"
  status_code     = "200"
  response_models = "${var.response_models}"
}

resource "aws_api_gateway_integration_response" "integration-response" {
  depends_on         = ["aws_api_gateway_integration.integration"]
  rest_api_id        = "${var.rest_api_id}"
  resource_id        = "${var.resource_id}"
  http_method        = "${aws_api_gateway_method.method.http_method}"
  status_code        = "${aws_api_gateway_method_response.response.status_code}"
  response_templates = "${var.response_templates}"
}