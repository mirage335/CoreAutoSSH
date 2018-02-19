_generate_compile_bash_prog() {
	rm "$scriptAbsoluteFolder"/ubiquitous_bash.sh
	
	"$scriptAbsoluteLocation" _compile_bash cautossh cautossh
	
	#"$scriptAbsoluteLocation" _package
} 
