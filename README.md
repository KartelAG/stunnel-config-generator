# stunnel-config-generator

---

_serverlist.txt_ - should have the list of all nodes to start stunnel

_stunnel-header.conf_ - common stunnel parameters

---

**Prerequisite:**

1. python3.5 or higher
2. your user should be in sudoers (because iptables is used to redirect traffic)

**Usage:**

1. Make sure that serverlist.txt is up to date
1. Enter node internal ip to INT_IP variable in _config-stunnel.sh_. If NAT is used between the nodes, use EXT_IP parameter
1. start _config-stunnel.sh_ script
