resource "aws_iam_role" "my-codepipeline-role" {
  name = "my-codepipeline-role"


  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      },
    ]
  })


}

data "aws_iam_policy_document" "tf-cicd-pipeline-policies" {
  statement {
    sid       = ""
    actions   = ["codestar-connections:UseConnection"]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    sid       = ""
    actions   = ["cloudwatch:*", "s3:*", "codebuild:*"]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "tf-cicd-pipeline-policy" {
  name        = "tf-cicd-pipeline-policy"
  path        = "/"
  description = "Pipeline policy"
  policy      = data.aws_iam_policy_document.tf-cicd-pipeline-policies.json
}

resource "aws_iam_policy_attachment" "tf-cicd-pipeline-attachment" {
  name       = "my-attachment"
  policy_arn = aws_iam_policy.tf-cicd-pipeline-policy.arn
  roles      = [aws_iam_role.my-codepipeline-role.id]
}

resource "aws_iam_role" "my-codebuild-role" {
  name = "my-codebuild-role"


  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy_document" "tf-cicd-build-policies" {
  statement {
    sid       = ""
    actions   = ["logs:*", "s3:*", "codebuild:*", "iam:*"]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "tf-cicd-buid-policy" {
  name        = "tf-cicd-build-policy"
  path        = "/"
  description = "Codebuild policy"
  policy      = data.aws_iam_policy_document.tf-cicd-pipeline-policies.json
}

resource "aws_iam_policy_attachment" "tf-cicd-codebuild-attachment1" {
  name       = "my-attachment2"
  policy_arn = aws_iam_policy.tf-cicd-pipeline-policy.arn
  roles      = [aws_iam_role.my-codebuild-role.id]
}

resource "aws_iam_policy_attachment" "tf-cicd-pipeline-attachment2" {
  name       = "my-attachment3"
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  roles      = [aws_iam_role.my-codebuild-role.id]
}