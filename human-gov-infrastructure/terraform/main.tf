provider "aws" {
  region = "us-east-1"
}

# Create HumanGov infrastructures for each state
module "aws_humangov_infrastructure" {
  source     = "./modules/aws_humangov_infrastructure" # source of all aws infrastructure to be created
  for_each   = toset(var.states) # Loop through all the states and create aws infrastructures
  state_name = each.value
}
