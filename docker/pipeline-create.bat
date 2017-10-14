docker-compose down -v
docker-compose build
docker-compose up -d
sleep 30
curl --silent  --user "admin:password" "http://192.168.99.100:8081/artifactory/ui/onboarding/createDefaultRepos" -X POST -H 'Content-Type: application/json;charset=UTF-8'  -H 'Accept: application/json, text/plain, */*' --data-binary '{"repoTypeList": ["Maven"],"fromOnboarding": false}'

