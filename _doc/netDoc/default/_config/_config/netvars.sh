#currentReversePort=""
#currentMatchingReversePorts=""
#currentReversePortOffset=""
#matchingOffsetPorts=""
#matchingReversePorts=""
#matchingEMBEDDED=""

#Creates "${matchingOffsetPorts}[@]" from "${matchingReversePorts}[@]".
#Intended for public server tunneling (ie. HTTPS).
# ATTENTION: Overload with 'ops' .
_offset_reversePorts() {
	local currentReversePort
	local currentMatchingReversePorts
	local currentReversePortOffset
	for currentReversePort in "${matchingReversePorts[@]}"
	do
		let currentReversePortOffset="$currentReversePort"+100
		currentMatchingReversePorts+=( "$currentReversePortOffset" )
	done
	matchingOffsetPorts=("${currentMatchingReversePorts[@]}")
	export matchingOffsetPorts
}


#####Network Specific Variables
#Statically embedded into monolithic ubiquitous_bash.sh/cautossh script by compile .

# WARNING Must use unique netName!
export netName=default
export netNameShort='dflt'
export gatewayName=gw-"$netName"
export LOCALSSHPORT=22


#Optional equivalent to LOCALSSHPORT, also respected for tunneling ports from other services.
export LOCALLISTENPORT="$LOCALSSHPORT"

# ATTENTION: Mostly future proofing. Due to placement of autossh within a 'while true' loop, associated environment variables are expected to have minimal, if any, effect.
#Poll time must be double network timeouts.
export AUTOSSH_FIRST_POLL=45
export AUTOSSH_POLL=45
#export AUTOSSH_GATETIME=0
export AUTOSSH_GATETIME=15
#export AUTOSSH_PORT=0
#export AUTOSSH_DEBUG=1
#export AUTOSSH_LOGLEVEL=7

_get_reversePorts() {
	export matchingReversePorts
	matchingReversePorts=()
	export matchingEMBEDDED="false"

	local matched

	local testHostname
	testHostname="$1"
	[[ "$testHostname" == "" ]] && testHostname=$(hostname -s)

	if [[ "$testHostname" == "$netNameShort"'pc' ]] || [[ "$testHostname" == '*' ]]
	then
		matchingReversePorts+=( '20001' )
		matched='true'
	fi
	
	if [[ "$testHostname" == "$netNameShort"'rpi' ]] || [[ "$testHostname" == '*' ]]
	then
		matchingReversePorts+=( '20002' )
		matched='true'
	fi
	
	if [[ "$testHostname" == "$netNameShort"'srv' ]] || [[ "$testHostname" == '*' ]]
	then
		matchingReversePorts+=( '20009' )
		matched='true'
	fi
	
	if [[ "$testHostname" == "$netNameShort"'a1' ]] || [[ "$testHostname" == '*' ]]
	then
		matchingReversePorts+=( '20010' )
		matched='true'
	fi
	
	if [[ "$testHostname" == "$netNameShort"'a2' ]] || [[ "$testHostname" == '*' ]]
	then
		matchingReversePorts+=( '20011' )
		matched='true'
	fi
	
	
	if ! [[ "$matched" == 'true' ]] || [[ "$testHostname" == '*' ]]
	then
		matchingReversePorts+=( '20020' )
	fi

	export matchingReversePorts
}
_get_reversePorts
export reversePorts=("${matchingReversePorts[@]}")
export EMBEDDED="$matchingEMBEDDED"

_offset_reversePorts
export matchingOffsetPorts

export keepKeys_SSH='true'
