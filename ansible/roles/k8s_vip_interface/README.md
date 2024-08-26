 I had some issues with the k8s_vip_interface role. 
 for somereason when you use dhcp for an ip address it will use the routes assigned to it from the router 
 i had to use dhcpoveride to get the vip network to not be default route