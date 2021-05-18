nmcli c mod enp0s3 connection.zone internal
nmcli c mod enp0s8 connection.zone external
firewall-cmd --get-active-zone
firewall-cmd --zone=external --add-masquerade --permanent
firewall-cmd --zone=external --query-masquerade
firewall-cmd --reload
firewall-cmd --permanent --direct --add-rule ipv4 nat POSTROUTING 0 -o enp0s8 -j MASQUERADE
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 \
  -i enp0s3 -o enp0s8 -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 \
  -i enp0s8 -o enp0s3 -m state --state RELATED,ESTABLISHED -j ACCEPT
firewall-cmd --reload
firewall-cmd --add-service http --permanent --zone=internal
firewall-cmd --add-service https --permanent --zone=internal
firewall-cmd --add-service ssh --permanent --zone=internal
firewall-cmd --add-service dns --permanent --zone=internal
firewall-cmd --add-service dhcp --permanent --zone=internal
firewall-cmd --add-service tftp --permanent --zone=internal
firewall-cmd --permanent --zone=public --add-service mountd
firewall-cmd --permanent --zone=public --add-service rpc-bind
firewall-cmd --permanent --zone=public --add-service nfs
firewall-cmd --add-port 8080/tcp --permanent --zone=internal
firewall-cmd --add-port 6443/tcp --permanent --zone=internal
firewall-cmd --add-port 9000/tcp --permanent --zone=internal
firewall-cmd --add-port 22623/tcp --permanent --zone=internal
firewall-cmd --add-port 9000-9999/tcp --permanent --zone=internal
firewall-cmd --add-port 10250-10259/tcp --permanent --zone=internal
firewall-cmd --add-port 4789/udp --permanent --zone=internal
firewall-cmd --add-port 6081/udp --permanent --zone=internal
firewall-cmd --add-port 9000-9999/udp --permanent --zone=internal
firewall-cmd --add-port 30000-32767/tcp --permanent --zone=internal
firewall-cmd --add-port 30000-32767/udp --permanent --zone=internal
firewall-cmd --add-port 2379-2380/tcp --permanent --zone=internal
firewall-cmd --add-port 443/tcp --permanent --zone=internal
firewall-cmd --permanent --zone=internal --add-service mountd
firewall-cmd --permanent --zone=internal --add-service rpc-bind
firewall-cmd --permanent --zone=internal --add-service nfs

firewall-cmd --add-service http --permanent --zone=external
firewall-cmd --add-service https --permanent --zone=external
firewall-cmd --add-service ssh --permanent --zone=external
firewall-cmd --add-service dns --permanent --zone=external
firewall-cmd --add-service dhcp --permanent --zone=external
firewall-cmd --add-port 8080/tcp --permanent --zone=external
firewall-cmd --add-port 6443/tcp --permanent --zone=external
firewall-cmd --add-port 9000/tcp --permanent --zone=external
firewall-cmd --add-port 22623/tcp --permanent --zone=external
firewall-cmd --add-port 9000-9999/tcp --permanent --zone=external
firewall-cmd --add-port 10250-10259/tcp --permanent --zone=external
firewall-cmd --add-port 443/tcp --permanent --zone=external
firewall-cmd --add-port 4789/udp --permanent --zone=external
firewall-cmd --add-port 6081/udp --permanent --zone=external
firewall-cmd --add-port 9000-9999/udp --permanent --zone=external
firewall-cmd --add-port 30000-32767/tcp --permanent --zone=external
firewall-cmd --add-port 30000-32767/udp --permanent --zone=external
firewall-cmd --add-port 2379-2380/tcp --permanent --zone=external

firewall-cmd --reload

firewall-cmd --list-all --zone=internal
firewall-cmd --list-all --zone=external
firewall-cmd --direct --get-all-rules

