data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_sfn_state_machine" "drp_orchestrator" {
  name     = "DRP-Redis-Failover-Orchestrator"
  role_arn = aws_iam_role.step_functions_role.arn

  definition = jsonencode({
    Comment = "Orquestador DRP para validación y flush de Redis"
    StartAt = "AprobacionManual"
    States = {
      AprobacionManual = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke.waitForTaskToken"
        Parameters = {
          FunctionName = "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:askUser"
          Payload = {
            "TaskToken.$"   = "$$.Task.Token"
            "ExecutionId.$" = "$$.Execution.Id"
          }
        }
        Next = "VerificarAprobacion"
      }
      VerificarAprobacion = {
        Type   = "Pass"
        Result = "Aprobado, continuando DRP..."
        End    = true
      }
    }
  })
}