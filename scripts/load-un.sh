#!/usr/bin/env bash
set -x

while read -r procPID; do
    kill -9 "$procPID"
done <<< "$(jobs -p)"
