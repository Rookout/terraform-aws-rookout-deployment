
resource "aws_iam_role" "task_exec_role" {
  count               = var.custom_iam_task_exec_role_arn == "" ? 1 : 0
  name                = "${var.environment}-task-exec-role"
  managed_policy_arns = [aws_iam_policy.task_exec_role[0].arn]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Sid    = "1"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "task_exec_role" {
  count = var.custom_iam_task_exec_role_arn == "" ? 1 : 0
  name  = "${var.environment}-secret-manager-get-secret"
  path  = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ]
        Resource = ["arn:aws:logs:*"]
      }
    ]
  })
}