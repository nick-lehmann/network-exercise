ip netns add ns1
ip link add veth0 type veth peer name veth1

echo "# Network interfaces"
ip address

echo "# Configuring network namespace ns1"
ip netns exec ns1 bash
ip link set dev veth1 netns ns1
ip address add 192.168.1.2/24 dev veth1
ip link set dev veth1 up
exit

# Host namespace?
echo "# Configuring..."
ip address add 192.168.1.1/24 dev veth0
ip link set dev veth0 up

# Testing
ping 192.168.1.2