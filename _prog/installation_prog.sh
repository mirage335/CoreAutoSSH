
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

_package_prog() {
	rm -f "$safeTmp"/package/USAGE.html
	rm -f "$safeTmp"/package/TiddlySaver.jar
	
	rm -f "$safeTmp"/package/_config/_config/netvars.sh.png
}

_package() {
	export ubPackage_enable_ubcp='false'
	"$scriptAbsoluteLocation" _package_procedure "$@"
}



