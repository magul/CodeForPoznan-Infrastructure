package_update: true

# https://www.kabisa.nl/tech/cost-saving-with-nat-instances/
bootcmd:
  - sysctl -w net.ipv4.ip_forward=1
  - iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE

ssh_authorized_keys:
%{for key in keys ~}
  - ${key}
%{endfor ~}