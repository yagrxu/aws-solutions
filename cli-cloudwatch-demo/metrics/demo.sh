#!/bin/bash

get_current_directory() {
    current_file="${PWD}/${0}"
    echo "${current_file%/*}"
}

CWD=$(get_current_directory)
echo "$CWD"

cd $CWD

START_TIME=`TZ=UTC date -j -v -30M +%Y-%m-%dT%H:%M:%SZ`
END_TIME=`TZ=UTC date +%Y-%m-%dT%H:%M:%SZ`
echo $START_TIME
echo $END_TIME
aws cloudwatch get-metric-data --metric-data-queries file://./metric-data-queries.json --start-time $START_TIME --end-time $END_TIME --no-cli-pager
