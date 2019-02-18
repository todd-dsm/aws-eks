#!/usr/bin/env bash
# shellcheck disable=SC2154
# If you prefer to try-out ExternalDNS in one of the existing hosted-zones you can skip this step
set -x

myZone="yo.${TF_VAR_dns_zone}."

# Create a DNS zone which will contain the managed DNS records.
#aws route53 create-hosted-zone --name "$myZone" --caller-reference "yo-test-$(date +%s)"

# capture the zone ID
zoneID="$(aws route53 list-hosted-zones-by-name --output json --dns-name "$myZone" | jq -r '.HostedZones[0].Id')"

# list associated name servers
aws route53 list-resource-record-sets --output json --hosted-zone-id "$zoneID" \
    --query "ResourceRecordSets[?Type == 'NS']" | jq -r '.[0].ResourceRecords[].Value'
