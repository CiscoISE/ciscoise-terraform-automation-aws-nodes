resource "aws_autoscaling_group" "my_asg" {
  name_prefix = ""
  desired_capacity   = 2
  max_size           = 2
  min_size           = 2
  target_group_arns = "" # need to define as per nlb configuration 
  # Launch Template
  launch_template {
    id      = aws_launch_template.ise_launch_template.id
    version = ""
  }
  tag {
  }      
}
