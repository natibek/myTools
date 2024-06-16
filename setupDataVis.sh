#!/usr/bin/env bash

if [ "$#" -eq 1 ]; then
    fuldir=$DATAVISDIR$1
    export PROJECT=$1
else
    read -p "Current project: " project
    export PROJECT=$project
    fuldir=$DATAVISDIR$project
fi    

echo $fuldir 
if [ -d $fuldir ]; then

    # while
    # 	port=$(shuf -n 1 -i 49152-65535)
    # 	netstat -atun | grep -q "$port"
    # do
    # 	continue
    # done

    for port in $(seq 8000 8200); do # ports I want to use
	if [ ! "$(netstat -atun | grep "$port")" ]; then # checks if the port is not in use
	    cd $fuldir
	    code .
	    python3 -m http.server $port & . > /dev/null 2> /dev/null # this is not working well. not silent
	    firefox localhost:$port 2> /dev/null # to quiet to output
	    echo -e "\nHTTP SERVER OPEN ON PORT: http://localhost:$port\n"
	    success=1
	    break
	fi
    done

    if ! $sucess; then
	echo -e "\nNo Free ports between 8000 and 8200"
    fi
    
else
    echo $fuldir "Directory does not exist."
fi

