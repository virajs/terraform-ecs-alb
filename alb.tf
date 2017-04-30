data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket" "alb_log_bucket" {
  count  = "${var.with-cloudwatch == "true" ? 1 : 0}"
  bucket = "${var.ecs-alb-log-bucket}"
  acl    = "private"

  policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::alb-logs-front-end/AWSLogs/*",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.main.arn}"
        ]
      }
    }
  ]
}
POLICY
}

resource "aws_alb" "ecs-alb" {
  name            = "ecs-alb-front-end"
  subnets         = ["${aws_subnet.ecs-alb.*.id}"]
  security_groups = ["${aws_security_group.lb_sg.id}"]

  access_logs {
    enabled   = "${var.with-cloudwatch == "true"}"
    bucket    = "${aws_s3_bucket.alb_log_bucket.bucket}"
  }
}
