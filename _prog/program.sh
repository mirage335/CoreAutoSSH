#####Program

_buildSSHbase() {
	
	if [[ "$keepKeys" == "" ]]
	then
		rm "$scriptAbsoluteFolder"/id_rsa >/dev/null 2>&1
		rm "$scriptAbsoluteFolder"/id_rsa.pub >/dev/null 2>&1
	fi
	
	cp -n -d --preserve=all "$sshBase"/id_rsa "$scriptAbsoluteFolder"/ >/dev/null 2>&1
	cp -n -d --preserve=all "$sshBase"/id_rsa.pub "$scriptAbsoluteFolder"/ >/dev/null 2>&1
	
	cat "$scriptAbsoluteFolder"/known_hosts >> ~/.ssh/known_hosts
	
	#cat "$scriptAbsoluteFolder"/config >> ~/.ssh/config
	echo >> ~/.ssh/config
	echo "#""$netName" >> ~/.ssh/config
	echo Include '"'"~/.ssh/""$netName""/config"'"' >> ~/.ssh/config
	echo >> ~/.ssh/config
	
	! [[ -e "$scriptAbsoluteFolder"/id_rsa ]] && ssh-keygen -b 4096 -t rsa -N "" -f "$scriptAbsoluteFolder"/id_rsa
	
	_prepare
	
	_ssh_copy_id_gateway
	
}

_build() {
	#_tryExec _idleBuild
	_buildSSHbase
}

#Typically launches an application - ie. through virtualized container.
_launch() {
	_autosshService
}

#Typically gathers command/variable scripts from other (ie. yaml) file types (ie. AppImage recipes).
_collect() {
	false
}

#Typical program entry point, absent any instancing support.
_enter() {
	_launch
}

#Typical program entry point.
_main() {
	_start
	
	_collect
	
	_enter
	
	_stop
}
