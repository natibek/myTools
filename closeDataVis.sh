#!/usr/bin/env bash

c=0

while IFS=' ' read -ra pid ; do
    if [ -n $pid ]; then
	echo "CLOSED PORT ASSOCIATED WITH PID $pid"
	kill -9 $pid
	((c++))
    fi
done < <(ps | grep python3)

# for result in $(ps | grep python3 | cut -d" " -f3); do
#     if [ -n "$result" ]; then
	
# 	echo "CLOSED PORT $result"
# 	kill -9 $result
# 	((c++))
#     fi

# done

if [ $c -eq 0 ]; then
    echo "No python servers to close"
fi

function closeVSCODE() {
    while IFS=' ' read -r id; do
	if [ -n "$id" ]; then
	    wmctrl -i -c "$id"
	    echo "CLOSED VS Code"
	    unset PROJECT
	    break
	fi
    done < <(wmctrl -l | grep "$PROJECT - Visual Studio Code")

    # for windowId in $(wmctrl -l | grep "$PROJECT - Visual Studio Code" | cut -d" " -f1); do
    # 	if [ -n "$windowId" ]; then
    # 	    wmctrl -i -c "$windowId"
    # 	    echo "CLOSED VS Code"
    # 	fi
    # done

}

if [ -n "$PROJECT" ] ; then
    closeVSCODE
else
    read -p 'Project to close: ' PROJECT
    closeVSCODE
fi
exit
