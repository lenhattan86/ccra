#!/usr/bin/env bash
if [ -z "$1" ]
then
  message="regular update"
else
  message=$1
fi

#find ./* -size +50M | cat >> .gitignore
git add --all
git commit -m "$message"
git push https://lenhattan86:nhattan86@github.com/lenhattan86/HiBench-7.0.git
