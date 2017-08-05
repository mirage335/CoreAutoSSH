#####Local Environment Management (Resources)

_extra() {
	true
}

_prepareSSHbase() {
	mkdir -p "$sshDir"
	
	cp -d --preserve=all "$scriptAbsoluteFolder"/cautossh "$sshDir"/ > /dev/null 2>&1
	cp -d --preserve=all "$scriptAbsoluteFolder"/ops "$sshDir"/ > /dev/null 2>&1
	
	chmod 600 "$scriptAbsoluteFolder"/id_rsa > /dev/null 2>&1
	chmod 600 "$scriptAbsoluteFolder"/id_rsa.pub > /dev/null 2>&1
	
	cp -n -d --preserve=all "$scriptAbsoluteFolder"/id_rsa "$sshDir"/ > /dev/null 2>&1
	cp -n -d --preserve=all "$scriptAbsoluteFolder"/id_rsa.pub "$sshDir"/ > /dev/null 2>&1
	cp -n -d --preserve=all "$scriptAbsoluteFolder"/id_rsa "$sshBase"/ > /dev/null 2>&1
	cp -n -d --preserve=all "$scriptAbsoluteFolder"/id_rsa.pub "$sshBase"/ > /dev/null 2>&1
	
	cp -d --preserve=all "$scriptAbsoluteFolder"/config "$sshDir"/ > /dev/null 2>&1
	#cp -n -d --preserve=all "$scriptAbsoluteFolder"/config "$sshBase"/ > /dev/null 2>&1
	
	cp -n -d --preserve=all "$scriptAbsoluteFolder"/known_hosts "$sshDir"/ > /dev/null 2>&1
	cp -n -d --preserve=all "$scriptAbsoluteFolder"/known_hosts "$sshBase"/ > /dev/null 2>&1
}

_prepare() {
	
	mkdir -p "$safeTmp"
	
	mkdir -p "$shortTmp"
	
	mkdir -p "$logTmp"
	
	_prepareSSHbase
	
	_extra
}
