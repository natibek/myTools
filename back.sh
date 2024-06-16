#!/usr/bin/env bash

if [ -n "$@" ]
then
    cd ..
else  
    count=0
    while [ $count -lt "$@" ]
    do
	cd ..
	echo $count
	((count++))
    done;
fi
