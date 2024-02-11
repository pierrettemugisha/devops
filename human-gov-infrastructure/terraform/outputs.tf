output "state_infrastructure_outputs" {
  value = {
    for state, infrastructure in module.aws_humangov_infrastructure :
    state => {
      dynamodb_table = infrastructure.state_dynamodb_table
      s3_bucket      = infrastructure.state_s3_bucket
    }
  }
}
