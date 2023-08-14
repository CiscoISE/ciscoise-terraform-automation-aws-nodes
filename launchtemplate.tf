resource "aws_launch_template" "ise_launch_template" {
  name = "${local.stack_name}-00_ISE_cluster_launch_template"
  user_data = {
    InstanceType = var.ise_instance_type
    KeyName = var.key_pair_name
    ImageId = local.mappings["CiscoISEAMI"][data.aws_region.current.name][local.mappings["ISEVersionMap"][var.ise_version]["Code"]]
    BlockDeviceMappings = [
      {
        DeviceName = "/dev/sda1"
        Ebs = {
          VolumeType = "gp2"
          DeleteOnTermination = "true"
          Encrypted = var.ebs_encrypt
          VolumeSize = var.storage_size
        }
      }
    ]
    SecurityGroupIds = [
      aws_security_group.ise_security_group.arn
    ]
  }
}




