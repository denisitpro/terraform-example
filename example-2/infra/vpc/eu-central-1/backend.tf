/* read configure aws profile
https://developer.hashicorp.com/terraform/language/settings/backends/s3#profile */
data "terraform_remote_state" "global" {
  backend = "s3"
  config = {
    bucket  = "c1-s3-global-vars-v4"
    key     = "v1/global-vars-v1.tfstate"
    region  = "eu-central-1"
    profile = "c1_global_ro"
  }
}