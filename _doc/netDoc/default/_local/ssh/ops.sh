if [[ "$envGuard" != "$scriptAbsoluteLocation" ]]
then
	# Must be much less than half "ConnectTimeout" value .
	export netTimeout='18'

	export envGuard="$scriptAbsoluteLocation"
fi

export netName=default
export netNameShort='dflt'

export sshHomeBase="$HOME"/.ssh

_here_ssh_config() {
	cat << CZXWXcRMTo8EmM8i4d
Host gw-$netName
	ProxyCommand "$sshDir/cautossh" _ssh_proxy_server-$netName
	User gateway
	IdentityFile "$sshLocalSSH/rev_gate"
	#IdentityFile "$sshLocalSSH/id_rsa"
	#IdentityFile "$HOME/.ssh/id_rsa"
	Compression no
	#Aggressively disconnects quickly. Comment if margins insufficient for high-latency.
	ConnectTimeout 18
	ConnectionAttempts 3
	ServerAliveInterval 3
	ServerAliveCountMax 3

Host server-$netName
	ProxyCommand "$sshDir/cautossh" _ssh_proxy_server-$netName
	User commonadmin
	#IdentityFile "$sshLocalSSH/id_rsa"

Host pc-$netName
	ProxyCommand "$sshDir/cautossh" _ssh_proxy_pc-$netName
	User commonadmin
	#IdentityFile "$sshLocalSSH/id_rsa"

Host raspi-$netName
	ProxyCommand "$sshDir/cautossh" _ssh_proxy_raspi-$netName
	User commonadmin
	#IdentityFile "$sshLocalSSH/id_rsa"
	
Host lan-$netName
	ProxyCommand "$sshDir/cautossh" _ssh_proxy_lan-$netName
	User root
	#IdentityFile "$sshLocalSSH/id_rsa"
	
Host wan-$netName
	ProxyCommand "$sshDir/cautossh" _ssh_proxy_wan-$netName
	User root
	#IdentityFile "$sshLocalSSH/id_rsa"

# Example. No production use. Diagnostic use intended.
Host rcmd-$netName
	ProxyCommand "$sshDir/cautossh" _ssh_proxy_rcmd-$netName
	User root
	#IdentityFile "$sshLocalSSH/id_rsa"

# Example. No production use. Diagnostic use intended.
Host rsrv-$netName
	ProxyCommand "$sshDir/cautossh" _ssh_proxy_rsrv-$netName
	User root
	#IdentityFile "$sshLocalSSH/id_rsa"
	
Host a1-$netName
	ProxyCommand "$sshDir/cautossh" _ssh_proxy_a1-$netName
	User commonadmin
	#IdentityFile "$sshLocalSSH/id_rsa"
	
Host a2-$netName
	ProxyCommand "$sshDir/cautossh" _ssh_proxy_a2-$netName
	User commonadmin
	#IdentityFile "$sshLocalSSH/id_rsa"

Host *-$netName*
	Compression yes
	ExitOnForwardFailure yes
	ConnectTimeout 72
	ConnectionAttempts 3
	ServerAliveInterval 6
	ServerAliveCountMax 9
	#PubkeyAuthentication yes
	#PasswordAuthentication no
	StrictHostKeyChecking no
	UserKnownHostsFile "$sshLocalSSH/known_hosts"
	IdentityFile "$sshLocalSSH/id_rsa"
	#Cipher aes256-gcm@openssh.com
	#Ciphers aes256-gcm@openssh.com,aes128-ctr,aes192-ctr,aes256-ctr,arcfour256,arcfour128,aes128-gcm@openssh.com,chacha20-poly1305@openssh.com,aes128-cbc,3des-cbc,blowfish-cbc,cast128-cbc,aes192-cbc,aes256-cbc,arcfour

CZXWXcRMTo8EmM8i4d
}

_check_LAN_default() {
	ip addr show | grep '192\.168\.241' > /dev/null 2>&1 && return 0
	return 1
}

# Reference only. No production use. May be used diagnositcally to detect local access to Router WAN ( "192.168.125.1" or "10.0.2.15" ) .
_check_CMD_default() {
	ip addr show | grep '192\.168\.242' > /dev/null 2>&1 && return 0
	return 1
}
# Reference only. No production use. May be used diagnositcally to detect local access to Router WAN ( "192.168.125.1" or "10.0.2.15" ) .
_check_SRV_default() {
	ip addr show | grep '192\.168\.249' > /dev/null 2>&1 && return 0
	return 1
}
# Reference only. No production use. May be used diagnositcally to detect local access to Router WAN ( "192.168.125.1" or "10.0.2.15" ) .
_check_WAN_default() {
	ip addr show | grep '192\.168\.125' > /dev/null 2>&1 && return 0
	return 1
}
# Reference only. No production use. May be used diagnositcally to detect local access to Router WAN ( "192.168.125.1" or "10.0.2.15" ) .
_check_ALL_default() {
	_check_LAN_default && return 0
	_check_CMD_default && return 0
	_check_SRV_default && return 0
	_check_WAN_default && return 0
	return 1
}

_ssh_proxy_server-default() {
	_start
	
	export netTimeout=3

	#_check_SRV_default && _proxy 192.168.249.109 22

	# Static IP or Domain Name
	_proxy 10.0.2.15 20009
	
	_proxy 192.168.125.19 20009
	
	_proxyTor_reverse "$netNameShort"srv ztsrmow4ftffhfpa.onion

	_stop
}

_ssh_proxy_pc-default() {
	_start
	
	#Wired (primary)
	_check_LAN_default && _proxy 192.168.241.101 22
	
	#WiFi (secondary)
	_check_LAN_default && _proxy 192.168.241.181 22
	
	_proxySSH_reverse "$netNameShort"pc gw-default
	
	if [[ "$proxySSH_loopGuard" != "true" ]]
	then
		export proxySSH_loopGuard="true"
		
		#Wired (primary)
		_proxySSH raspi-default 22 192.168.241.101
		
		#WiFi (secondary)
		_proxySSH raspi-default 22 192.168.241.181
		
		true
	fi

	_proxyTor_reverse "$netNameShort"pc g66dagdgsg5c3awy.onion

	_stop
}

_ssh_proxy_raspi-default() {
	_start
	
	#Wired (primary)
	_check_LAN_default && _proxy 192.168.241.102 22
	
	#WiFi (secondary)
	_check_LAN_default && _proxy 192.168.241.182 22
	
	_proxySSH_reverse "$netNameShort"rpi gw-default
	
	if [[ "$proxySSH_loopGuard" != "true" ]]
	then
		export proxySSH_loopGuard="true"
		
		#Wired (primary)
		_proxySSH pc-default 22 192.168.242.102
		
		#WiFi (secondary)
		_proxySSH pc-default 22 192.168.242.182
		
		true
	fi

	_proxyTor_reverse "$netNameShort"rpi 3rsuxfquoaxvuysk.onion

	_stop
}

_ssh_proxy_lan-default() {
	_start

	#_check_LAN_default && _proxy 192.168.241.1 30122
	_proxy 10.0.2.15 30122

	if [[ "$proxySSH_loopGuard" != "true" ]]
	then
		export proxySSH_loopGuard="true"
		_proxySSH raspi-default 30122 192.168.241.1
		true
	fi

	#_proxyTor_reverse "$netNameShort"lan xxxxxxxxxxxxxxxxx.onion

	_stop
}

_ssh_proxy_wan-default() {
	_start

	#_check_ALL_default && _proxy 192.168.125.1 30022
	_proxy 10.0.2.15 30022

	if [[ "$proxySSH_loopGuard" != "true" ]]
	then
		export proxySSH_loopGuard="true"
		_proxySSH raspi-default 30022 192.168.125.1
		true
	fi

	#_proxyTor_reverse "$netNameShort"wan xxxxxxxxxxxxxxxxx.onion

	_stop
}

_ssh_proxy_rcmd-default() {
	_start

	#_check_ALL_default && _proxy 192.168.242.1 30222
	_proxy 10.0.2.15 30222

	if [[ "$proxySSH_loopGuard" != "true" ]]
	then
		export proxySSH_loopGuard="true"
		_proxySSH raspi-default 30222 192.168.242.1
		true
	fi

	#_proxyTor_reverse "$netNameShort"wan xxxxxxxxxxxxxxxxx.onion

	_stop
}

_ssh_proxy_rsrv-default() {
	_start

	#_check_ALL_default && _proxy 192.168.249.1 30922
	_proxy 10.0.2.15 30922

	if [[ "$proxySSH_loopGuard" != "true" ]]
	then
		export proxySSH_loopGuard="true"
		_proxySSH raspi-default 30922 192.168.249.1
		true
	fi

	#_proxyTor_reverse "$netNameShort"wan xxxxxxxxxxxxxxxxx.onion

	_stop
}

_ssh_proxy_a1-default() {
	_start

	_check_LAN_default && _proxy 192.168.241.110 22
	
	_proxySSH_reverse "$netNameShort"a1 gw-default

	if [[ "$proxySSH_loopGuard" != "true" ]]
	then
		export proxySSH_loopGuard="true"
		_proxySSH raspi-default 22 192.168.241.110
		true
	fi

	_proxyTor_reverse "$netNameShort"a1 gleuvenp7jeakrzu.onion

	_stop
}

_ssh_proxy_a2-default() {
	_start

	_check_LAN_default && _proxy 192.168.241.111 22
	
	_proxySSH_reverse "$netNameShort"a2 gw-default

	if [[ "$proxySSH_loopGuard" != "true" ]]
	then
		export proxySSH_loopGuard="true"
		_proxySSH raspi-default 22 192.168.241.111
		true
	fi

	_proxyTor_reverse "$netNameShort"a2 2f7yguixvq43minu.onion

	_stop
}

_tunnel_public() {
	## Optional - tunnel public web server.

	export overrideLOCALLISTENPORT=443
	_get_reversePorts
	_offset_reversePorts
	export overrideMatchingReversePort="${matchingOffsetPorts[0]}"

	_torServer_SSH
	_autossh
}


#Daemon commands. Do not define unless multi-gateway
#redundancy is needed. Tor services redundancy is
#expected to be far more reliable than such fallbacks.
_ssh_autoreverse() {
	_get_reversePorts
	_torServer_SSH
	_autossh

	#_autossh firstGateway
	#_autossh secondGateway

	#return '0'

	_tunnel_public
}

#Hooks "_setup_ssh" after other operations complete. Typically used to install special files (eg. machine specific keys).
_setup_ssh_extra() {
	true
}

#Hooks "_setup" before "_setup_ssh" .
_setup_pre() {
	true
}

#Hooks "_setup" after "_setup_ssh" .
_setup_prog() {
	true
}

