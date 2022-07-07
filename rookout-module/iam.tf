
resource "aws_iam_role" "task_exec_role" {
    name = "rookout-task-exec-role"
    managed_policy_arns = [aws_iam_policy.secret_manager_read.arn]
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action =  ["sts:AssumeRole"]
                Effect = "Allow"
                Sid = "1"
                Principal = {
                    Service = "ecs-tasks.amazonaws.com"
                }
            }
        ]
   })
} 


resource "aws_iam_policy" "secret_manager_read" {
    name = "secret-manager-get-secret"
    path = "/"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {   
                Effect = "Allow"
                Action =  [
                    "secretsmanager:GetResourcePolicy",
                    "secretsmanager:GetSecretValue",
                    "secretsmanager:DescribeSecret",
                    "secretsmanager:ListSecretVersionIds",
                    "secretsmanager:ListSecrets",
                    "kms:Decrypt"
                ]
                Resource = [
                    "*",
                    "arn:aws:secretsmanager:eu-west-1:032275105219:secret:rookout-token-WluvBl"
                    ]
            },
            {   
                Effect = "Allow"
                Action =  [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:DescribeLogStreams",
                    "logs:PutLogEvents"
                ]
                Resource = ["arn:aws:logs:*"]
            },
            {
                Effect = "Allow"
                Action = [
                    "ecr:GetAuthorizationToken",
                    "ecr:BatchCheckLayerAvailability",
                    "ecr:BatchGetImage",
                    "ecr:GetDownloadUrlForLayer"

                ]
                Resource = ["*"]
            }
        ]
  })
}