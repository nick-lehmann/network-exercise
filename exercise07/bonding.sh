# Bonding setup
modprobe bonding miimon=100 mode=802.3ad lacp_rate=fast

# Ethernet setup
ip netns add host1
ip netns add host2

# Create interfaces
ip link add veth11 type veth peer name veth21
ip link add veth12 type veth peer name veth22

# Namespace: Host1
ip link set dev veth11 netns host1
ip link set dev veth12 netns host1

ip netns exec host1 bash -c "
  ip link add dev bond1 type bond
  ip link set dev veth11 master bond1
  ip link set dev veth12 master bond1
  ip address add 192.168.1.1/24 dev bond1
  ip link set dev bond1 up
  ip link set dev veth11 up
  ip link set dev veth12 up"

# Namespace: Host2
ip link set dev veth21 netns host2
ip link set dev veth22 netns host2

ip netns exec host2 bash -c "
  ip link add dev bond2 type bond
  ip link set dev veth21 master bond2
  ip link set dev veth22 master bond2
  ip address add 192.168.1.2/24 dev bond2
  ip link set dev bond2 up
  ip link set dev veth21 up
  ip link set dev veth22 up"

# Try it
ip netns exec host1 bash -c "
  echo 'Try with both interfaces up'
  ping -I bond1 -c 1 192.168.1.2
  echo 'Works with both interfaces'
  
  echo 'Setting only veth11 down'
  ip link set dev veth11 down
  sleep 1
  ping -I bond1 -c 1 192.168.1.2
  echo 'Works only with veth12'

  echo 'Setting only veth12 down'
  ip link set dev veth11 up
  ip link set dev veth12 down
  sleep 1
  ping -I bond1 -c 1 192.168.1.2
  echo 'Works only with veth11'
"