data "aws_iam_policy" "AWSCodeCommitFullAccess" {
  arn = "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess"
}

# creazione ruolo
resource "aws_iam_role" "cd" {
  name               = "CodeDeployRole"
  assume_role_policy = file("assume-role-policy.json")
}

# associazione policy a ruolo
resource "aws_iam_policy_attachment" "role-attach" {
  name       = "role-attachment"
  roles      = [aws_iam_role.cd.name]
  policy_arn = data.aws_iam_policy.AWSCodeCommitFullAccess.arn
}

resource "aws_iam_instance_profile" "wp" {
  name  = "CodeDeployRoleWP"
  role =  aws_iam_role.cd.name
}
