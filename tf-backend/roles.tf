data "aws_iam_policy" "backend" {
  arn = module.remote_state.terraform_iam_policy.arn
}

resource "aws_iam_role" "backend" {
  name               = "terraform-backend"
  description        = "Allows access to terrafrom backend"
  assume_role_policy = data.aws_iam_policy_document.backend-assume-role.json
}

resource "aws_iam_role_policy_attachment" "sto-readonly-role-policy-attach" {
  role       = "${aws_iam_role.backend.name}"
  policy_arn = "${data.aws_iam_policy.backend.arn}"
}

data "aws_iam_policy_document" "backend-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }
}

data "aws_caller_identity" "current" {
}
