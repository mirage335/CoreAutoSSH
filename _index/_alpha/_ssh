#!/usr/bin/env bash

#####Utilities.
#Retrieves absolute path of current script, while maintaining symlinks, even when "./" would translate with "readlink -f" into something disregarding symlinked components in $PWD.
#However, will dereference symlinks IF the script location itself is a symlink. This is to allow symlinking to scripts to function normally.
#Suitable for allowing scripts to find other scripts they depend on. May look like an ugly hack, but it has proven reliable over the years.
_getScriptAbsoluteLocation() {
	local absoluteLocation
	if [[ (-e $PWD\/$0) && ($0 != "") ]]
			then
	absoluteLocation="$PWD"\/"$0"
	absoluteLocation=$(realpath -s "$absoluteLocation")
			else
	absoluteLocation="$0"
	fi

	if [[ -h "$absoluteLocation" ]]
			then
	absoluteLocation=$(readlink -f "$absoluteLocation")
	fi

	echo $absoluteLocation
}

#Suitable for allowing scripts to find other scripts they depend on.
_getScriptAbsoluteFolder() {
	dirname "$(_getScriptAbsoluteLocation)"
}

_discoverResource() {
	local testDir
	
	testDir="$testScriptAbsoluteFolder" ; [[ -e "$testDir"/"$1" ]] && echo "$testDir"/"$1" && return
	testDir="$testScriptAbsoluteFolder"/.. ; [[ -e "$testDir"/"$1" ]] && echo "$testDir"/"$1" && return
	testDir="$testScriptAbsoluteFolder"/../.. ; [[ -e "$testDir"/"$1" ]] && echo "$testDir"/"$1" && return
	testDir="$testScriptAbsoluteFolder"/../../.. ; [[ -e "$testDir"/"$1" ]] && echo "$testDir"/"$1" && return
}

export testScriptAbsoluteLocation=$(_getScriptAbsoluteLocation)
export testScriptAbsoluteFolder=$(_getScriptAbsoluteFolder)

export machineName=$(basename "$testScriptAbsoluteFolder")

export commandName=$(basename "$testScriptAbsoluteLocation")

##### Script Call

cautosshLocation=$(_discoverResource cautossh)
opsLocation=$(_discoverResource ops)

export SSHUSER=

#Import settings.
. "$cautosshLocation"

#Launch in directory with needed resources.
"$cautosshLocation" "$commandName" "$SSHUSER""$machineName" "$@"


