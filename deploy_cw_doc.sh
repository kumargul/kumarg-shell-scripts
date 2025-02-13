#!/usr/bin/env bash
set -xe
_autoscaling_create_or_update_tags() {
    local key="$1"
    local val="$2"
    local tags="ResourceId=$(hostname),ResourceType=auto-scaling-group,Key=$key,Value=$val,PropagateAtLaunch=true"
    echo "Update $key tag for ASG: $(hostname)"
    aws autoscaling create-or-update-tags --tags "$tags"
  }
cwReload(){
  app_media_bucket="esb-prod-software"
  if [[ {{Environment}} != "prod ]]; then
    app_media_bucket="esb-software"
  fi
  aws s3 cp s3://"$app_media_bucket"/CW/curatedCW.json /tmp/curatedCW.json
  cd /opt/aws/amazon-cloudwatch-agent/bin
  amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:///tmp/curatedCW.json
}
updateASGTag(){
  ASG=$(hostname)
  echo "Update tag for ASG: $ASG"
  partition=$(lsblk -l |grep / |awk '{print $1}')
  fs_type=$(df -Th |grep -v tmpfs | grep "^/dev" | awk '{print $2}')
  _autoscaling_create_or_update_tags "EBS_Partition" "$partition"
  _autoscaling_create_or_update_tags "EBS_FSType" "$fs_type"
}
updateEC2Tags(){
  instance_arr=( $(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" \
  "Name=tag:Name,Values=$(hostname)" --query 'Reservations[].Instances[*].InstanceId' --output text))
  aws ec2 create-tags --resources $instance_arr --tags Key=$1,Value=enabled
}
addSSMTagstoASG(){
  envtag="prod"
  if [[ {{Environment}} != "prod ]]; then
    envtag="nonp"
  fi
  memory_alarm_tag=$(aws ssm get-parameter --name "$envtag_asg_memory_alarm" --query 'Parameter.Value' --output text)
  disk_alarm_tag=$(aws ssm get-parameter --name "$envtag_disk_alarm" --query 'Parameter.Value' --output text)
  status_alarm_tag=$(aws ssm get-parameter --name "$envtag_status_alarm" --query 'Parameter.Value' --output text)
  
  echo "Updating Ec2 tags with SSM parameters"
  updateEC2Tags $memory_alarm_tag
  updateEC2Tags $disk_alarm_tag
  updateEC2Tags $status_alarm_tag
  echo "Updating ASG tags with SSM parameters"
  _autoscaling_create_or_update_tags $memory_alarm_tag "enabled"
  _autoscaling_create_or_update_tags $disk_alarm_tag "enabled"
  _autoscaling_create_or_update_tags $status_alarm_tag "enabled"
}
# Main script
cwReload
updateASGTag
addSSMTagstoASG