# kumarg-shell-scripts

This directory contains various shell scripts for AWS operations and automation. Below is a brief description of each script:

- **backup_s3_bucket.sh**: Script to backup an S3 bucket to another S3 bucket.
- **cleanup_old_amis.sh**: Script to clean up old AMIs and their associated snapshots.
- **create_ec2_instance.sh**: Script to create an EC2 instance with specified parameters.
- **delete_old_snapshots.sh**: Script to delete old EC2 snapshots based on retention policy.
- **monitor_ec2_instances.sh**: Script to monitor EC2 instances and send alerts based on CPU usage.
- **rotate_iam_keys.sh**: Script to rotate IAM user access keys.
- **start_stop_ec2_instances.sh**: Script to start and stop EC2 instances based on a schedule.
- **update_security_groups.sh**: Script to update security group rules.

## Example: backup_s3_bucket.sh

This script backs up an S3 bucket to another S3 bucket.

### Usage

1. Ensure you have the AWS CLI installed and configured:
   ```sh
   aws configure

2. Run the script:

  `./backup_s3_bucket.sh source-bucket target-bucket`

3. The script will copy all objects from the source bucket to the target bucket.

