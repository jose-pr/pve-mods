#!/bin/bash
jq -e ".master_node == \"`hostname`\"" /etc/pve/ha/manager_status