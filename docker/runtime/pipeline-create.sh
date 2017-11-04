#!/usr/bin/env bash

sleep 60
echo "initialize artifactory default maven repos"
curl --silent  --user "admin:password" "http://artifactory:8081/artifactory/ui/onboarding/createDefaultRepos" -X POST -H 'Content-Type: application/json;charset=UTF-8'  -H 'Accept: application/json, text/plain, */*' --data-binary '{"repoTypeList": ["Maven"],"fromOnboarding": false}'


serverurl="http://artifactory:8081"
base_url="https://$PUBLIC_IP_ADDRESS/artifactory"
echo "Set artifactory base url to ${base_url}"
escaped_base_url=$(echo ${base_url} | sed -e 's/[\/&]/\\&/g')

#Get current config
old_config=$(curl --insecure --user "admin:password" "http://artifactory:8081/artifactory/ui/generalConfig" -X GET)
#Set new base url
new_config=$(echo "${old_config}" | sed -r "s/\}/,\"customUrlBase\":\"${escaped_base_url}\"\}/g")

curl --silent --user "admin:password" "http://artifactory:8081/artifactory/ui/generalConfig" -X PUT -H 'Accept: application/json, text/plain, */*' -H 'Content-Type: application/json;charset=UTF-8' --data-binary "${new_config}"


