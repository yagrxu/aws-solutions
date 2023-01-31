#!/bin/sh
# env.sh

cat <<EOF
{
  "accessKeyId": "$GLOBAL_AWS_ACCESS_KEY_ID",
  "secretAccessKey": "$GLOBAL_AWS_SECRET_ACCESS_KEY"
}
EOF