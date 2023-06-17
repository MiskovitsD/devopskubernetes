#!/bin/sh

curl http://application.cubix.localhost:8080/webinar/message -X POST -d @../example.json -H "Content-Type: application/json"
