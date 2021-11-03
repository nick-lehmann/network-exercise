from scapy.all import *
from scapy.layers.inet import IP, UDP

dst = "127.0.0.1"
dport = 2323
text = "abc"

p = IP(dst=dst)/UDP(dport=dport)/"text"
send(p, 'lo')
