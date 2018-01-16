#!/usr/bin/env bash

docker-compose down -v
docker-compose build
docker-compose up -d
