
_package_ubcp_copy_prog() {
	if [[ -e "$scriptLib"/coreautossh/_lib/ubiquitous_bash/_local/ubcp ]]
	then
		_package_ubcp_copy_copy "$scriptLib"/coreautossh/_lib/ubiquitous_bash/_local/ubcp "$safeTmp"/package/_local/
		rm -f "$safeTmp"/package/_local/ubcp/package_ubcp-cygwinOnly.tar.gz
		return 0
	fi
	
	
	false
	
	cd "$outerPWD"
	return 1
	_stop 1
}




