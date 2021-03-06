#!/bin/bash
# FAIR License, Copyright (c) 2019 72Zn
# Usage of the works is permitted provided that this instrument is retained
# with the works, so that any entity that uses the works is notified of this
# instrument.  
# DISCLAIMER: THE WORKS ARE WITHOUT WARRANTY.

# usage examples:
#	./pwned.sh [pw1] [pw2] ...
#	./pwned.sh < <file_with_passwords>
#	echo pw | ./pwned.sh

PWNAPI="https://api.pwnedpasswords.com/range"

lookup_pwned_api() {
	local pass="$1"
	local pwhash=$(printf "%s" "$pass" | sha1sum | cut -d" " -f1)
	local curlrv=$(curl -s "$PWNAPI/${pwhash:0:5}")
	[ -z "$curlrv" ] && echo "$pass could not be checked" && return
	local result=$(echo "$curlrv" | grep -i "${pwhash:5:35}")

	if [ -n "$result" ]; then
		local occ=$(printf "%s" "${result}" | cut -d: -f2 | sed 's/[^0-9]*//g')
		printf "%s was found with %s occurances (hash: %s)\n" "$pass" "$occ" "$pwhash"
	else
		printf "%s was not found\n" "$pass"
	fi
}

if [ "$#" -lt 1 ]; then
	# read from file or stdin (one password per line)
	while IFS=$'\r\n' read -r pw; do
		lookup_pwned_api "$pw"
	done
else
	# read arguments
	for pw in "$@"; do
		lookup_pwned_api "$pw"
	done
fi

