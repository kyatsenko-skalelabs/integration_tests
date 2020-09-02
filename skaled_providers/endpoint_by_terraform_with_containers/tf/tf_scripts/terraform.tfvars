# region = "us-east-2"
# availability_zone = "us-east-2c"
region = "us-west-2"
availability_zone = "us-west-2c"
# instance_type = "t2.2xlarge" # 32Gb $0.371200 hourly
# instance_type = "t2.xlarge"   # 16Gb $0.185600 hourly
# instance_type = "t2.large"   # 8Gb  $0.092800 hourly
#instance_type = "t2.medium"    # 4Gb  $0.046400 hourly
instance_type = "t2.small"   # 2Gb  $0.023000 hourly
root_volume_size = 50
lvm_volume_size = 300
key_name = "elvis-oregon"
#path_to_pem = "/home/dimalit/.just_works/k2_aws.pem"
path_to_pem = "/home/dimalit/.just_works/elvis-oregon.pem"

spot_price = {"t2.small" = "0.007", "t2.medium" = "0.015", "t2.large" = "0.029", "t2.xlarge" = "0.056", "t2.2xlarge" = "0.112"}
