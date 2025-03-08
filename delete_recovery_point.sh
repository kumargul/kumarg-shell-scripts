#!/bin/bash

aws backup list-recovery-points-by-backup-vault --backup-vault-name $1 > rc.json

cat rc.json | jq -r '.RecoveryPoints[].RecoveryPointArn' > arn.txt

cat arn.txt | while read in;
do 
  aws backup delete-recovery-point --backup-vault-name $1 --recovery-point-arn "$in";
done

rm -rf arn.txt rc.json
