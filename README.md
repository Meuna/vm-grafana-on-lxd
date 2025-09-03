# vm-grafana-on-lxd

This repository provisions 3 VM on LXD using OpenTofu and deploys the following
stack with Ansible:
 - a clustered (although single node) VictoriaMetrics deployement,
 - and a Grafana server.

## Deployment

Provision the LXD VM:

```console
$ cd tofu
$ tofu init
$ tofu apply
```

Resolve the `vmgraf.local` domain with the LXD DNS server

```console
$ cd ..
$ sudo ./dns.sh
```

Deploy the stack:


```console
$ cd ansible
$ ansible-playbook playbooks/all.yaml
```

## UI end-points

* https://grafana.vmgraf.local:3000: Grafana (default auth: `admin/admin`)
* https://vm.vmgraf.local:8429: vmagent
* https://vm.vmgraf.local:8481/select/0/vmui: vmui
* https://vm.vmgraf.local:8427/select/0/vmui: vmui (proxied by vmauth, default bearer: `abcd`)

## Prometheus end-points

* https://vm.vmgraf.local:8480/insert/0/prometheus: vminsert
* https://vm.vmgraf.local:8427/insert/0/prometheus: vminsert (proxied by vmauth, default bearer: `abcd`)
* https://vm.vmgraf.local:8481/select/0/prometheus: vmselect
* https://vm.vmgraf.local:8427/select/0/prometheus: vmselect (proxied by vmauth, default bearer: `abcd`)

## Metrics end-points

* https://vm.vmgraf.local:8429/metrics: vmagent
* https://vm.vmgraf.local:8480/metrics: vminsert
* https://vm.vmgraf.local:8481/metrics: vmselect
* https://vm.vmgraf.local:8482/metrics: vmstorage
* https://vm.vmgraf.local:9100/metrics: node-exporter
* https://grafana.vmgraf.local:9100/metrics: node-exporter
* https://scrapped.vmgraf.local:9100/metrics: node-exporter
