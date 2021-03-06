#!/usr/bin/env bash


#Critical prerequsites.

_realpath_L() {
	if ! _compat_realpath_run -L . > /dev/null 2>&1
	then
		readlink -f "$@"
		return
	fi
	
	realpath -L "$@"
}

_realpath_L_s() {
	if ! _compat_realpath_run -L . > /dev/null 2>&1
	then
		readlink -f "$@"
		return
	fi
	
	realpath -L -s "$@"
}

_getAbsolute_criticalDep() {
	! type realpath > /dev/null 2>&1 && return 1
	! type readlink > /dev/null 2>&1 && return 1
	! type dirname > /dev/null 2>&1 && return 1
	
	#Known issue on Mac. See https://github.com/mirage335/ubiquitous_bash/issues/1 .
	! realpath -L . > /dev/null 2>&1 && return 1
	
	return 0
}
! _getAbsolute_criticalDep && exit 1

#####Utilities.
#Retrieves absolute path of current script, while maintaining symlinks, even when "./" would translate with "readlink -f" into something disregarding symlinked components in $PWD.
#However, will dereference symlinks IF the script location itself is a symlink. This is to allow symlinking to scripts to function normally.
#Suitable for allowing scripts to find other scripts they depend on. May look like an ugly hack, but it has proven reliable over the years.
_getScriptAbsoluteLocation() {
	if [[ "$0" == "-"* ]]
	then
		return 1
	fi
	
	local absoluteLocation
	if [[ (-e $PWD\/$0) && ($0 != "") ]] && [[ "$0" != "/"* ]]
	then
		absoluteLocation="$PWD"\/"$0"
		absoluteLocation=$(_realpath_L_s "$absoluteLocation")
	else
		absoluteLocation=$(_realpath_L "$0")
	fi
	
	if [[ -h "$absoluteLocation" ]]
	then
		absoluteLocation=$(readlink -f "$absoluteLocation")
		absoluteLocation=$(_realpath_L "$absoluteLocation")
	fi
	echo $absoluteLocation
}
alias getScriptAbsoluteLocation=_getScriptAbsoluteLocation

#Retrieves absolute path of current script, while maintaining symlinks, even when "./" would translate with "readlink -f" into something disregarding symlinked components in $PWD.
#Suitable for allowing scripts to find other scripts they depend on.
_getScriptAbsoluteFolder() {
	if [[ "$0" == "-"* ]]
	then
		return 1
	fi
	
	dirname "$(_getScriptAbsoluteLocation)"
}
alias getScriptAbsoluteFolder=_getScriptAbsoluteFolder


#Retrieves absolute path of parameter, while maintaining symlinks, even when "./" would translate with "readlink -f" into something disregarding symlinked components in $PWD.
#Suitable for finding absolute paths, when it is desirable not to interfere with symlink specified folder structure.
_getAbsoluteLocation() {
	if [[ "$1" == "-"* ]]
	then
		return 1
	fi
	
	if [[ "$1" == "" ]]
	then
		echo
		return
	fi
	
	local absoluteLocation
	if [[ (-e $PWD\/$1) && ($1 != "") ]] && [[ "$1" != "/"* ]]
	then
		absoluteLocation="$PWD"\/"$1"
		absoluteLocation=$(_realpath_L_s "$absoluteLocation")
	else
		absoluteLocation=$(_realpath_L "$1")
	fi
	echo "$absoluteLocation"
}
alias getAbsoluteLocation=_getAbsoluteLocation




#Generates random alphanumeric characters, default length 18.
_uid() {
	local uidLength
	! [[ -z "$1" ]] && uidLength="$1" || uidLength=18
	
	cat /dev/urandom 2> /dev/null | base64 2> /dev/null | tr -dc 'a-zA-Z0-9' 2> /dev/null | head -c "$uidLength" 2> /dev/null
}

#Demarcate major steps.
_messageNormal() {
	echo -e -n '\E[1;32;46m '
	echo -n "$@"
	echo -e -n ' \E[0m'
	echo
	return 0
}




_discoverResource() {
	local testDir
	
	testDir="$testScriptAbsoluteFolder" ; [[ -e "$testDir"/"$1" ]] && echo "$testDir"/"$1" && return
	testDir="$testScriptAbsoluteFolder"/.. ; [[ -e "$testDir"/"$1" ]] && echo "$testDir"/"$1" && return
	testDir="$testScriptAbsoluteFolder"/../.. ; [[ -e "$testDir"/"$1" ]] && echo "$testDir"/"$1" && return
	testDir="$testScriptAbsoluteFolder"/../../.. ; [[ -e "$testDir"/"$1" ]] && echo "$testDir"/"$1" && return
}


##### META SCRIPT #####

export testScriptAbsoluteLocation=$(_getScriptAbsoluteLocation)
export testScriptAbsoluteFolder=$(_getScriptAbsoluteFolder)

export machineName=$(basename "$testScriptAbsoluteFolder")

export commandName=$(basename "$testScriptAbsoluteLocation")

##### Script Call

cautosshLocation=$(_discoverResource cautossh)
opsLocation=$(_discoverResource ops)

#export SSHUSER=
[[ "$SSHUSER" != "" ]] && export SSHUSER="$SSHUSER"'@'

#Import settings.
. "$cautosshLocation"

localHTTPStunnelPort=$(_findPort)
targetHTTPStunnelAddress=localhost
targetHTTPStunnelPort=443

#Launch in directory with needed resources.

"$cautosshLocation" _ssh -o ConnectionAttempts=2 -C -L "$localHTTPStunnelPort":"$targetHTTPStunnelAddress":"$targetHTTPStunnelPort" "$SSHUSER""$machineName" -N &

sleep 3	# TODO: This could be better, as with current _vnc implementation . Then again, the web browser will be under manual control anyway, and some web services might react badly to port checking.

xdg-open "https://localhost:""$localHTTPStunnelPort"



