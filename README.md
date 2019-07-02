CoreAutoSSH
Self-contained, robust, multipath and reverse SSH configuration package. The framework SSH should have.

Dynamic configuration can now be achieved by scritping the "netName", "_here_ssh_config", and "_ssh_proxy_*" in an "ops" file. AutoSSH and Tor NAT punching are supported.


See USAGE.html.

# netDoc

The "netDoc" project is part of "CoreAutoSSH", under the "_doc" folder.

Checklists are included for "CoreAutoSSH" as well as "PFSense". Network topology for simulated and real physical networks is described.

# Workarounds

From the x11vnc man page.
	"You can use 3 Alt_L's (the Left "Alt" key) taps in
	a row (as described under -scrollcopyrect) instead to
	manually request a screen repaint when it is needed."

# Gateway Server

#Allows tunneling public ports.
#GatewayPorts yes
GatewayPorts clientspecified

#Configuiring a short client timeout is strongly recommended to prevent AutoSSH from encountering collisions with zombie tunnels.

#Aggressive.
ClientAliveInterval 3
ClientAliveCountMax 3

#Tolerant.
#/etc/ssh/sshd_config
ClientAliveInterval 6
ClientAliveCountMax 9


# Version
v3.1

Semantic versioning is applied. Major version numbers (v2.x) indicate a compatible API. Minor numbers indicate the current feature set has been tested for usability. Any git commits not tagged with a version number may be technically considered unstable development code. New functions present in git commits may be experimental.

In most user environments, the latest git repository code will provide the strongest reliability guarantees. Extra safety checks are occasionally added as possible edge cases are discovered.
