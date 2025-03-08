#!/usr/bin/env bash
set -e
#EC2=$1
#ENV=$2
ENV=$1

#if [ -z $EC2 ] || [ -z $ENV ]; then
if [ -z $ENV ]; then
  #echo "Usuage: $0 jh sit"
  echo "Usuage: $0 sit"
  exit 1
fi
instance_arr=( $(aws ec2 describe-instances --filters "Name=tag:Environment,Values=$ENV" \
"Name=instance-state-name,Values=running" --query 'Reservations[].Instances[*].InstanceId' --output text))

echo "Total EC2 instances: ${#instance_arr[@]}"

for instance in ${instance_arr[@]}; do 
  EC2=$(aws ec2 describe-instances --instance-id $instance \
  --filters "Name=instance-state-name,Values=running" --query \
  'Reservations[].Instances[*].[Tags[?Key == `Name`] | [0].Value]' --output text | cut -f2 -d"-")
  ESBCONFIG_VERSION=$(aws ec2 describe-instances --instance-id $instance \
  --filters "Name=instance-state-name,Values=running" --query \
  'Reservations[].Instances[*].[Tags[?Key == `esb_config_artifact_version`] | [0].Value]' --output text)
  CODEMAP_VERSION=$(aws ec2 describe-instances --instance-id $instance \
  --filters "Name=instance-state-name,Values=running" --query \
  'Reservations[].Instances[*].[Tags[?Key == `codemap_artifact_version`] | [0].Value]' --output text)
  ARTIFACT_VERSION=$(aws ec2 describe-instances --instance-id $instance \
  --filters "Name=instance-state-name,Values=running" --query \
  'Reservations[].Instances[*].[Tags[?Key == `artifact_version`] | [0].Value]' --output text)
  CERT_ARTIFACT_VERSION=$(aws ec2 describe-instances --instance-id $instance \
  --filters "Name=instance-state-name,Values=running" --query \
  'Reservations[].Instances[*].[Tags[?Key == `certificate_artifact_version`] | [0].Value]' --output text)
  echo "Current value for esb-$EC2-$ENV:"
  echo "esbconfig_artifact_verison: $ESBCONFIG_VERSION"
  echo "codemap_artifact_version: $CODEMAP_VERSION"
  echo "artifact_version: $ARTIFACT_VERSION"
  echo "certificate_artifact_version: $CERT_ARTIFACT_VERSION"

  if [[ "$ESBCONFIG_VERSION" == "None" ]] || [[ "$CODEMAP_VERSION" == "None" ]] || [[ "$ARTIFACT_VERSION" == "None" ]] || [[ "$CERT_ARTIFACT_VERSION" == "None" ]]; then
    echo "One to the tags from EC2 is empty..."
    echo "Check and fix tag manually"
    exit 2
  fi
  echo -e "Setting SSM Parameter values\n\n"
  # aws ssm put-parameter --name "/esb/$ENV/$EC2/esb_config_artifact_version" --type "String" --value $ESBCONFIG_VERSION --overwrite
  # aws ssm put-parameter --name "/esb/$ENV/$EC2/codemap_artifact_version" --type "String" --value $CODEMAP_VERSION --overwrite
  # aws ssm put-parameter --name "/esb/$ENV/$EC2/artifact_version" --type "String" --value $ARTIFACT_VERSION --overwrite
  # aws ssm put-parameter --name "/esb/$ENV/$EC2/certificate_artifact_version" --type "String" --value $CERT_ARTIFACT_VERSION --overwrite
done
