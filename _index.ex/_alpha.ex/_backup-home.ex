#!/usr/bin/env bash

#####Utilities

_command_messageNormal() {
	echo -e -n '\E[1;32;46m '
	echo -n "$@"
	echo -e -n ' \E[0m'
	echo
	return 0
}

_command_messageError() {
	echo -e -n '\E[1;33;41m '
	echo -n "$@"
	echo -e -n ' \E[0m'
	echo
	return 0
}



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

_command_getAbsolute_criticalDep() {
	! type realpath > /dev/null 2>&1 && return 1
	! type readlink > /dev/null 2>&1 && return 1
	! type dirname > /dev/null 2>&1 && return 1
	
	#Known issue on Mac. See https://github.com/mirage335/ubiquitous_bash/issues/1 .
	! realpath -L . > /dev/null 2>&1 && return 1
	
	return 0
}
! _command_getAbsolute_criticalDep && exit 1

#####Utilities.
#Retrieves absolute path of current script, while maintaining symlinks, even when "./" would translate with "readlink -f" into something disregarding symlinked components in $PWD.
#However, will dereference symlinks IF the script location itself is a symlink. This is to allow symlinking to scripts to function normally.
#Suitable for allowing scripts to find other scripts they depend on. May look like an ugly hack, but it has proven reliable over the years.
_command_getScriptAbsoluteLocation() {
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
alias getScriptAbsoluteLocation=_command_getScriptAbsoluteLocation

#Retrieves absolute path of current script, while maintaining symlinks, even when "./" would translate with "readlink -f" into something disregarding symlinked components in $PWD.
#Suitable for allowing scripts to find other scripts they depend on.
_command_getScriptAbsoluteFolder() {
	if [[ "$0" == "-"* ]]
	then
		return 1
	fi
	
	dirname "$(_command_getScriptAbsoluteLocation)"
}
alias getScriptAbsoluteFolder=_command_getScriptAbsoluteFolder

#Retrieves absolute path of parameter, while maintaining symlinks, even when "./" would translate with "readlink -f" into something disregarding symlinked components in $PWD.
#Suitable for finding absolute paths, when it is desirable not to interfere with symlink specified folder structure.
_command_getAbsoluteLocation() {
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
alias getAbsoluteLocation=_command_getAbsoluteLocation



#Retrieves absolute path of parameter, while maintaining symlinks, even when "./" would translate with "readlink -f" into something disregarding symlinked components in $PWD.
#Suitable for finding absolute paths, when it is desirable not to interfere with symlink specified folder structure.
_command_getAbsoluteFolder() {
	if [[ "$1" == "-"* ]]
	then
		return 1
	fi
	
	local absoluteLocation=$(_getAbsoluteLocation "$1")
	dirname "$absoluteLocation"
}



_command_discoverResource() {
	[[ "$commandScriptAbsoluteFolder" == "" ]] && return 1
	
	local testDir
	
	testDir="$commandScriptAbsoluteFolder" ; [[ -e "$testDir"/"$1" ]] && echo "$testDir"/"$1" && return
	testDir="$commandScriptAbsoluteFolder"/.. ; [[ -e "$testDir"/"$1" ]] && echo "$testDir"/"$1" && return
	testDir="$commandScriptAbsoluteFolder"/../.. ; [[ -e "$testDir"/"$1" ]] && echo "$testDir"/"$1" && return
	testDir="$commandScriptAbsoluteFolder"/../../.. ; [[ -e "$testDir"/"$1" ]] && echo "$testDir"/"$1" && return
	
	return 1
}

_command_safeBackup() {
	! type _command_getAbsolute_criticalDep > /dev/null 2>&1 && return 1
	! _command_getAbsolute_criticalDep && return 1
	
	[[ ! -e "$commandScriptAbsoluteLocation" ]] && exit 1
	[[ ! -e "$commandScriptAbsoluteFolder" ]] && exit 1
	
	#Fail sooner, avoiding irrelevant error messages. Especially important to cases where an upstream process has already removed the "$safeTmp" directory of a downstream process which reaches "_stop" later.
	! [[ -e "$1" ]] && return 1
	
	[[ "$1" == "" ]] && return 1
	[[ "$1" == "/" ]] && return 1
	[[ "$1" == "-"* ]] && return 1
	
	[[ "$1" == "/home" ]] && return 1
	[[ "$1" == "/home/" ]] && return 1
	[[ "$1" == "/home/$USER" ]] && return 1
	[[ "$1" == "/home/$USER/" ]] && return 1
	[[ "$1" == "/$USER" ]] && return 1
	[[ "$1" == "/$USER/" ]] && return 1
	
	[[ "$1" == "/root" ]] && return 1
	[[ "$1" == "/root/" ]] && return 1
	[[ "$1" == "/root/$USER" ]] && return 1
	[[ "$1" == "/root/$USER/" ]] && return 1
	[[ "$1" == "/$USER" ]] && return 1
	[[ "$1" == "/$USER/" ]] && return 1
	
	[[ "$1" == "/tmp" ]] && return 1
	[[ "$1" == "/tmp/" ]] && return 1
	
	[[ "$1" == "$HOME" ]] && return 1
	[[ "$1" == "$HOME/" ]] && return 1
	
	! type realpath > /dev/null 2>&1 && return 1
	! type readlink > /dev/null 2>&1 && return 1
	! type dirname > /dev/null 2>&1 && return 1
	! type basename > /dev/null 2>&1 && return 1
	
	return 0
}




##### Command Functions
_command_prepare_search() {
	_command_messageNormal "Preparing - search"

	echo "criticalBackupPrefix= ""$criticalBackupPrefix"

	#Current directory for preservation.
	export commandOuterPWD=$(_command_getAbsoluteLocation "$PWD")

	export commandScriptAbsoluteLocation=$(_command_getScriptAbsoluteLocation)
	export commandScriptAbsoluteFolder=$(_command_getScriptAbsoluteFolder)
	export machineName=$(basename "$commandScriptAbsoluteFolder")
	export commandName=$(basename "$commandScriptAbsoluteLocation")
	export criticalScriptLocation=$(_command_discoverResource cautossh)
	export opsLocation=$(_command_discoverResource ops)

	echo "commandScriptAbsoluteLocation= ""$commandScriptAbsoluteLocation"
	echo "commandScriptAbsoluteFolder= ""$commandScriptAbsoluteFolder"
	echo "machineName= ""$machineName"
	echo "commandName= ""$commandName"
	echo "criticalScriptLocation= ""$criticalScriptLocation"
	echo "opsLocation= ""$opsLocation"
	
	[[ "$commandScriptAbsoluteLocation" == "" ]] && _command_messageError 'blank: commandScriptAbsoluteLocation' && exit 1
	[[ "$commandScriptAbsoluteFolder" == "" ]] && _command_messageError 'blank: commandScriptAbsoluteFolder' && exit 1
	[[ "$machineName" == "" ]] && _command_messageError 'blank: machineName' && exit 1
	[[ "$commandName" == "" ]] && _command_messageError 'blank: commandName' && exit 1
	[[ "$criticalScriptLocation" == "" ]] && _command_messageError 'blank: criticalScriptLocation' && exit 1
	
}

_command_prepare_rsync_backup_config() {
	_command_messageNormal "Preparing - config"
	
	if ! criticalBackupSource=$("$criticalScriptLocation" _rsync_backup_remote "$machineName" "$criticalSourcePath" "$criticalUser" "$commandName")
	then
		echo "$criticalBackupSource"
		_command_messageError 'fail: '"$criticalScriptLocation"' _rsync_backup_remote'
	fi
	export criticalBackupSource
	
	if ! criticalBackupDestination=$("$criticalScriptLocation" _rsync_backup_local "$criticalDestinationPrefix" "$criticalDestinationPath" "$criticalUser" "$commandName")
	then
		echo "$criticalBackupDestination"
		_command_messageError 'fail: '"$criticalScriptLocation"' _rsync_backup_local'
	fi
	export criticalBackupDestination
	
	[[ "$relativeBackup" != "true" ]] && export criticalBackupDestination="$commandScriptAbsoluteFolder"/"$criticalBackupDestination"
	[[ "$relativeBackup" == "true" ]] && export criticalBackupDestination='./'"$criticalBackupDestination"
	export criticalBackupDestination
	
	echo "criticalBackupSource= ""$criticalBackupSource"
	echo "criticalBackupDestination= ""$criticalBackupDestination"
}



# Set by script.
export criticalBackupSource=""
export criticalBackupDestination=""

##### Config

#blank (default: 'root' if script name not '-home' or '' if script name '-home'), or 'username'
export criticalUser=""
#blank (default: '/' if 'criticalUser=root' or '' if script name '-home'), or '/path/to/source'
export criticalSourcePath=""
#blank, or 'name', or '[./]path/to/destination' (if 'relativeBackup=true')
export criticalDestinationPath=""

#blank (default: '_arc'), or '_subfolder_name'
export criticalDestinationPrefix=""

#blank, or 'true'
export relativeBackup=""

#####

_command_prepare_search

_command_prepare_rsync_backup_config

! "$criticalScriptLocation" _rsync_command_check_backup_dependencies && exit 1

! "$criticalScriptLocation" _prepare_rsync_backup_env "$criticalBackupSource" "$criticalBackupDestination" && exit 1

_command_messageNormal "Main - copying backup."
#cd "$commandOuterPWD"

# DANGER: WARNING: ATTENTION: Modify to enable "--delete" after testing.

echo "EXAMPLE: "
echo sudo -n "$criticalScriptLocation"' _rsync -A -X -x -avz --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/home/*/.gvfs"} --delete '"$criticalBackupSource" "$criticalBackupDestination"/fs
echo

sudo -n "$criticalScriptLocation" _rsync -A -X -x -avz --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/home/*/.gvfs"} "$criticalBackupSource" "$criticalBackupDestination"/fs
#true

[[ "$?" -gt "0" ]] && _command_messageError "FAIL" && exit 1

sleep 2

! type bup > /dev/null 2>&1 && exit 1

_command_messageNormal "Main - versioning backup."

export criticalAbsoluteBackupDestination=$(_command_getAbsoluteLocation "$criticalBackupDestination")
cd "$criticalBackupDestination"
export commandAbsolutePWD=$(_command_getAbsoluteLocation "$PWD")

[[ "$commandAbsolutePWD" != "$criticalAbsoluteBackupDestination" ]] && _command_messageError 'fail: commandAbsolutePWD= '"$commandAbsolutePWD"' != criticalAbsoluteBackupDestination= '"$criticalAbsoluteBackupDestination"

if [[ ! -e "./.bup" ]]
then
	sudo -n "$criticalScriptLocation" _bupNew
	#true
	
	[[ ! -e "./.bup" ]] && _command_messageError 'fail: _bupNew' && exit 1
fi

! sudo -n chown root:root "./.bup" && _command_messageError 'chown: '"./.bup"
! sudo -n chmod 700 "./.bup" && _command_messageError 'chmod: '"./.bup"

sudo -n "$criticalScriptLocation" _bupStore
#true

[[ "$?" -gt "0" ]] && _command_messageError "FAIL" && exit 1

exit 0







