from scapy.all import *
from scapy.layers.inet import IP, TCP

send(IP(dst="127.0.0.1") / TCP(dport=4242, flags="SP") / "bla")