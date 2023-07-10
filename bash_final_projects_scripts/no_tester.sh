#!/bin/bash
echo "$number"

if [[ $1 -eq $2 ]]; then echo "the numbers are equal";
elif [[ $1 -gt $2 ]]; then echo "the first is greater";
elif [[ $1 -lt $2 ]]; then echo "the first is lesser"
fi
~
