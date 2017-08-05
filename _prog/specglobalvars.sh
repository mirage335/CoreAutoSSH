
export sshBase="$HOME"/.ssh
export sshDir="$sshBase"/"$netName"

export pidFile="$sshDir"/pid
export pidFileExternal="$sshDir"/pidext
export externalDaemonPID="u8R4I2"

[[ "$X11USER" == "" ]] && [[ "$SSHUSER" != "" ]] && export X11USER="$SSHUSER"

if [[ "$SSHUSER"  != "" ]]
then
	export SSHUSER="$SSHUSER"'@'
fi

export AUTOSSH_FIRST_POLL=45
export AUTOSSH_POLL=45
#export AUTOSSH_GATETIME=0
export AUTOSSH_GATETIME=15

#export AUTOSSH_PORT=0

#export AUTOSSH_DEBUG=1
#export AUTOSSH_LOGLEVEL=7


