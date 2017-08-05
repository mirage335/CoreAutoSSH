##### Core

_autosshExternal() {
	/usr/bin/autossh -M 0 -F "$sshDir"/config -R $reversePort:localhost:22 "$gatewayName" -N &
	echo "$!" > "$pidFileExternal"
	
	autosshPID=$(cat "$pidFileExternal")
	#_pauseForProcess "$autosshPID"
	wait "$autosshPID"
}

_autossh() {
	
	while true
	do
		#echo test
		#echo "$reversePort"
		
		_autosshExternal
		
		sleep 30
		
		if [[ "$EMBEDDED" != "" ]]
		then
			sleep 270
		fi
		
	done
	
}

#Executes non-default self function in background (ie. as daemon).
_autosshDaemon() {
	_prepare
	
	if _daemonStatus
	then
		exit
	fi
	
	nohup "$scriptAbsoluteLocation" _autossh >/dev/null 2>&1 &
	echo "$!" > "$pidFile"
	
	#ls "$pidFile" > /dev/tty
	#cat "$pidFile" > /dev/tty
}

_autosshService() {
	
	_autosshDaemon
	
}

_ssh_copy_id_gateway() {
	_start
	
	#ssh-copy-id -i "$scriptAbsoluteFolder"/id_rsa.pub user@server "$@"
	
	_stop
}

_reversessh() {
	_start
	
	ssh -F "$sshDir"/config -R $reversePort:localhost:22 "$gatewayName" -N "$@"
	
	_stop
}

#"$1" == hostname
#"$2" == port
_testRemotePort() {
	local localPort
	localPort=$(_findPort)
	
	_timeout 3 ssh -F "$sshDir"/config "$1" -L "$localPort":localhost:"$2" -N > /dev/null 2>&1 &
	sleep 2
	nmap localhost -p "$localPort" -sV | grep 'ssh' > /dev/null 2>&1
}

_ssh() {
	_start
	
	ssh -F "$sshDir"/config "$@"
	
	_stop
}

#Builtin version of ssh-copy-id.
_ssh_copy_id() {
	_start
	
	"$scriptAbsoluteLocation" _ssh "$@" 'mkdir -p "$HOME"/.ssh'
	cat "$scriptAbsoluteFolder"/id_rsa.pub | "$scriptAbsoluteLocation" _ssh "$@" 'cat - >> "$HOME"/.ssh/authorized_keys'
	
	_stop
}
alias _ssh-copy-id=_ssh_copy_id

# TODO Add optional code using _findPort .
_vnc() {
	_start
	
	let vncPort="$reversePort"+10
	
	#https://wiki.archlinux.org/index.php/x11vnc#SSH_Tunnel
	#ssh -t -L "$vncPort":localhost:"$vncPort" "$@" 'sudo x11vnc -display :0 -auth /home/USER/.Xauthority'
	
	"$scriptAbsoluteLocation" _ssh -C -c aes256-gcm@openssh.com -m hmac-sha1 -o ConnectTimeout=3 -o ConnectionAttempts=2 -o ServerAliveInterval=5 -o ServerAliveCountMax=5 -o ExitOnForwardFailure=yes -f -L "$vncPort":localhost:"$vncPort" "$@" 'x11vnc -rfbport '"$vncPort"' -timeout 8 -xkb -display :0 -auth /home/'"$X11USER"'/.Xauthority'
	#-noxrecord -noxfixes -noxdamage
	
	sleep 3
	
	#vncviewer -encodings "copyrect tight zrle hextile" localhost:"$vncPort"
	vncviewer localhost:"$vncPort"
	
	_stop
}
