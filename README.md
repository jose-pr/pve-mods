Modification/utils added to Proxmox that maybe of interest to others.

# Virtual Private Address
Assign a VIP to the cluster, which the current master in a cluster should hold. Usefull for single ip to remember and 
when running other services such as PSQL Cluster on it.

Use keepalived, with a health check to decide which is has priority/is master.

# PSQL
Run Postgres on proxmox with a HA setup to enable use of proxmox /etc/pve shared storage, 
and utilize proxmox current HA master as the primary node for PSQL.

Goal is to use it a HA cluster in a 2 Proxmox Node setup with a QDevice. 
And DB be able to use Proxmox internals to keep track of quorom and configuration changes.

Main use would be running K3S LXC or VMs on each node and setting up a HA kubernetes cluster on top of Proxmox
with PSQL as its DB.
