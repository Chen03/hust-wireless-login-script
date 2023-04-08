#!/usr/bin/env bash

if { [ -z "$1" ] || [ -z "$2" ] ;} \
  && { [ -z "$HUST_USERNAME" ] || [ -z "$HUST_PASSWORD" ] ;}
then
  printf "No username nor password detected in arguments or environment.\n"
  printf "Usage:\n"
  printf "\thust.sh <username> <password>\n"
  printf "OR:\n\tenv HUST_USERNAME=\"U202110000\" HUST_PASSWORD=\"123456\" ./hust.sh\n"
  printf "Example: \n\thust.sh U202110000 123456\n"
  exit 1
fi

response=$(curl -s http://www.baidu.com/)
if [ -z "$1" ] || [ -z "$2" ]
then
  username=$HUST_USERNAME
  password=$HUST_PASSWORD
else
  username=$1
  password=$2
fi

# Test the response html are redirected or not
if [[ "$response" == *"baidu"* ]]
then
  echo "You're already logged in."
elif [[ "$response" == *"eportal"* ]] # Redirected to redirection page //123.123.123.123
then
  # Get the query string
  query=$(echo "$response" | awk 'match($0, /\?.*["'\'']/) {print substr($0, RSTART+1, RLENGTH-2)}')
  if [ -z "$query" ]; then
    echo "Match failed. The response is: $response"
    exit 1
  fi

  # Post login query
  if result=$(curl -s \
    -d "userId=$username" \
    -d "password=$password" \
    --data-urlencode "queryString=$query" \
    -d "service=" \
    -d "operatorPwd=" \
    -d "validCode=" \
    -d "passwordEncrypt=false" \
    "http://192.168.50.3:8080/eportal/InterFace.do?method=login" \
    | jq '.result')
  then
    if [[ "$result" == "\"success\"" ]]; then
      echo "Login successfully."
    else
      echo "Login failed. The response is: $result"
    fi
  else
    echo "Post login request failed."
  fi
fi