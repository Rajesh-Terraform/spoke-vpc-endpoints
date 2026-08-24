data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        data.aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:${var.github_org}/${var.github_repository}:ref:refs/heads/${var.github_branch}"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name = "${var.project_name}-github-actions"

  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json

  tags = {
    Name        = "${var.project_name}-github-actions"
    Project     = var.project_name
    Environment = var.environment
  }
}

data "aws_iam_policy_document" "terraform" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:*",
      "iam:*",
      "logs:*",
      "kms:*"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "terraform" {
  name = "${var.project_name}-terraform-policy"

  role = aws_iam_role.github_actions.id

  policy = data.aws_iam_policy_document.terraform.json
}
