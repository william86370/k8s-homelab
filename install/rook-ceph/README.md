# The rook-ceph operator install via helmchart 


# Test rook-ceph cluster setup

- i am using 5tb external disks attached to my raspberry pi nodes to create a rook-ceph cluster

- currently i only have 1 raspberry pi

the raspbeerey pi sees the external volume as /dev/sda so im good there 
- i want to create the ceph cluster with 1 of exerything with the option to scale up later

i am going to label the nodes with the following labels to make the insstall easier
```
kubectl label node halfbaked disk=usb
```
k label node --all node-role.kubernetes.io/worker=""

k taint node halfbaked  node-role.kubernetes.io/master:NoSchedule

k taint node halfbaked allways-online="true":NoSchedule
k taint node halfbaked node-type/raspberrypi:NoSchedule

k label node halfbaked node-type/raspberrypi=""