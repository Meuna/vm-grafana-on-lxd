#!/bin/bash
resolvectl dns vm-grafana $(lxc network get vm-grafana ipv4.address | cut -d'/' -f1)
resolvectl domain vm-grafana '~vmgraf.local'