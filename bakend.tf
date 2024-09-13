terraform {
  backend "s3" {
    bucket = "infrastructureautomation"
    key    = "terraform"
    region = "ap-south-1"
  }
}
