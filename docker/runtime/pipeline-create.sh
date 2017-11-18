#!/usr/bin/env bash

retries=20
for i in `seq 1 ${retries}`; do
    login_http_code=$(curl --silent --output /dev/null --user admin:password  -w "%{http_code}" "http://artifactory:8081/artifactory/webapp/")
	if [ "${login_http_code}" = "200" ] || [ "${login_http_code}" = "401" ]; then
		echo "Artifactory is ready"
		break
	else
		if [ ${i} = ${retries} ]; then
			echo 'All retries used. Artifactory not running?'
			exit -1
		else
			echo "Artifactory is not ready (retry ${i} of ${retries})"
			sleep 10
		fi
	fi
done

#sleep 60
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


