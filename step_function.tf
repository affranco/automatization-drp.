resource "aws_sfn_state_machine" "drp_orchestrator" {
  name     = "DRP-Redis-Failover-Orchestrator"
  role_arn = aws_iam_role.step_functions_role.arn

  definition = jsonencode({
    Comment = "Orquestador DRP para validación y flush de Redis"
    StartAt = "AprobacionManual"
    States = {
      AprobacionManual = {
        Type = "Task"
        Resource = "arn:aws:states:::lambda:invoke.waitForTaskToken"
        Parameters = {
          # Este ARN se actualizará cuando creemos la Lambda askUser
          FunctionName = "arn:aws:lambda:ca-central-1:${data.aws_caller_identity.current.account_id}:function:askUser"
          Payload = {
            "TaskToken.$" = "$$.Task.Token"
            "ExecutionId.$" = "$$.Execution.Id"
          }
        }
        Next = "VerificarAprobacion"
      }
      VerificarAprobacion = {
        Type = "Pass"
        Result = "Aprobado, continuando DRP..."
        End = true
      }
    }
  })
}

# Data source para obtener el ID de la cuenta dinámicamente
data "aws_caller_identity" "current" {}