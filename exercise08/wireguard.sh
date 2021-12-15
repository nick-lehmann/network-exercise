# Namespace setup
ip netns add host1
ip netns add host2

# Create interfaces and move to namespaces
ip link add veth1 type veth peer name veth2
ip link set dev veth1 netns host1
ip link set dev veth2 netns host2

rm -rf host1 host2

mkdir host1 && cd host1
echo "================"
echo "Namespace: HOST1"
echo "================"
ip netns exec host1 bash -c "
  wg genkey > private
  (wg pubkey < private) > public
  
  ip link add wg1 type wireguard
  ip addr add 10.0.0.1/24 dev wg1
  wg set wg1 private-key ./private
  
  ip address add 192.168.1.1/24 dev veth1
  
  ip link set veth1 up
  ip link set wg1 up
"
cd ..

mkdir host2 && cd host2
echo "================"
echo "Namespace: HOST2"
echo "================"
ip netns exec host2 bash -c "
  wg genkey > private
  (wg pubkey < private) > public
  
  ip link add wg2 type wireguard
  ip addr add 10.0.0.2/24 dev wg2
  wg set wg2 private-key ./private

  ip address add 192.168.1.2/24 dev veth2
  
  ip link set veth2 up
  ip link set wg2 up
"
cd ..


echo "Configure wg1"
ip netns exec host1 bash -c "
  wg set wg1 \
    listen-port 51820 \
    peer $(cat ./host2/public) \
    allowed-ips 10.0.0.2/32 \
    endpoint 192.168.1.2:51820 
"

echo "Configure wg2"
ip netns exec host2 bash -c "
  wg set wg2 \
    listen-port 51820 \
    peer $(cat ./host1/public) \
    allowed-ips 10.0.0.1/32 \
    endpoint 192.168.1.1:51820 
"

ip netns exec host1 bash -c "
  ping -c 1 10.0.0.2
"