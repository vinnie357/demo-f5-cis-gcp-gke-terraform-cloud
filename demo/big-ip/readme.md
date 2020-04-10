# create partition and vxlan config
tmsh create auth partition k8s
tmsh create net tunnels vxlan fl-vxlan port 8472 flooding-type none
tmsh create net tunnels tunnel fl-vxlan key 1 profile fl-vxlan local-address 10.0.20.2
tmsh create net self 10.12.100.1 address 10.12.100.0/255.255.0.0 allow-service none vlan fl-vxlan

# get mac address for vxlan
tmsh show net tunnels tunnel fl-vxlan all-properties

eg:

    -------------------------------------------------
    Net::Tunnel: fl-vxlan
    -------------------------------------------------
    MAC Address                   **00:50:56:bb:70:8b**
    Interface Name                           fl-vxlan

# create the dummy node on k8s
using f5-bigip-node.yaml

kubectl apply -f \
    f5-bigip-node.yaml