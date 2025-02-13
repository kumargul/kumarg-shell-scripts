#!/bin/bash
# ==================================================================================================================
# This script is used to copy eindex media from eIndex-Dev SMC to other eIndex LHS specific SMCs.
# How to do it:
# Login to Jenkins EC2 instance in eIndex-dev SMC (PROVIDER.AUPIDEVP-SMC).
# Make sure the script is available within EC2 instance.
# Run this shell script as ./einedx-media-sync.sh <LHD Name: sw/gs/gw etc.> <Release name: Rel_20230329_1618>
# ===================================================================================================================
set -e

case "$1" in
	"gs")
	echo "Copying to GS UAT S3 Bucket"
	aws s3 sync s3://nonp-eindex-ohmpi-media/lhp_ohmpiInstall/applications/$2 \
    s3://uat-gs-eindex-media/lhp_ohmpiInstall/applications/$2 --sse
	echo "Setting correct ownership for GS UAT Bucket"
	aws s3 ls s3://uat-gs-eindex-media/lhp_ohmpiInstall/applications/$2 --recursive |\
    awk '{cmd="aws s3api put-object-acl --acl bucket-owner-full-control --bucket uat-gs-eindex-media --key "$4; system(cmd)}'
	;;
	
  "gw")
	echo "Copying to GW UAT S3 Bucket"
	aws s3 sync s3://nonp-eindex-ohmpi-media/lhp_ohmpiInstall/applications/$2 \
    s3://uat-gw-eindex-media/lhp_ohmpiInstall/applications/$2 --sse
	echo "Setting correct ownership for GS UAT Bucket"
	aws s3 ls s3://uat-gw-eindex-media/lhp_ohmpiInstall/applications/$2 --recursive |\
    awk '{cmd="aws s3api put-object-acl --acl bucket-owner-full-control --bucket uat-gw-eindex-media --key "$4; system(cmd)}'
  ;;
	
  "sw")
	echo "Copying to SW UAT S3 Bucket"
  aws s3 sync s3://nonp-eindex-ohmpi-media/lhp_ohmpiInstall/applications/$2 \
    s3://uat-sw-eindex-media/lhp_ohmpiInstall/applications/$2 --sse
  echo "Setting correct ownership for SW UAT Bucket"
  aws s3 ls s3://uat-sw-eindex-media/lhp_ohmpiInstall/applications/$2 --recursive |\
    awk '{cmd="aws s3api put-object-acl --acl bucket-owner-full-control --bucket uat-sw-eindex-media --key "$4; system(cmd)}'
  ;;

	*)
	echo "Usage pattern: $0 <LHD Name: sw/gs/gw etc.> <Release name: Rel_20230329_1618>"
	exit 1
esac