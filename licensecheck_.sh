#!/usr/bin/env bash

function check_license(){
	if $(pip show $@ | grep "mit");
	then
		echo BAD $@
	fi
}

function get_dependencies(){
	IFS=", "
	for dep in $(pip show $@ | grep "Requires" | cut -d":" -f2);
	do
		check_license $dep
		get_dependencies $dep
	done
}

function check_dependency(){
	for req in $(cat $@ | awk -F'[<>=~!\[]' '{ print $1 }');
	do
		echo $req
		get_dependencies $req
	done
}

check_dependency requirements.txt

