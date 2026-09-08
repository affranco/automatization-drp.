resource "aws_iam_role" "step_functions_role" {
  name = "DRP-StepFunctions-Master-Role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "states.amazonaws.com" }
    }]
  })

  # Política inline integrada para evitar recreaciones del rol
  inline_policy {
    name = "SFN-SNS-Publish"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Action   = "sns:Publish"
        Effect   = "Allow"
        Resource = aws_sns_topic.drp_war_room.arn
      }]
    })
  }
}