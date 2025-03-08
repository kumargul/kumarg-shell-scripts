#!/usr/bin/env bash

source /etc/profile.d/esb.sh
smc_account=$(aws sts get-caller-identity | jq -r .Account)
asadmin list-domains > /tmp/domainStatus.txt

if grep not /tmp/domainStatus.txt; then
  cat /tmp/domainStatus.txt | mailx -r "$(hostname)@health.nsw.gov.au" -s "$(hostname): domain(s) not running for SMC: $smc_account" ehnsw-esbsupport@health.nsw.gov.au ehnsw-integrationsupport@health.nsw.gov.au
fi

if [ -d /var/log/stunnel ] && ! pgrep stunnel >/dev/null; then
  echo "Stunnel is not running" | mailx -r "$(hostname)@health.nsw.gov.au" -s "$(hostname): Stunnel is not running for SMC: $smc_account" ehnsw-esbsupport@health.nsw.gov.au ehnsw-integrationsupport@health.nsw.gov.au
fi
