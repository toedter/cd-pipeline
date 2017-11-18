set PUBLIC_IP_ADDRESS=192.168.99.100
docker-compose down -v
docker-compose rm -f -v
docker-compose build
docker-compose up -d
