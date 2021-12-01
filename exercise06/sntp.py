from scapy.all import *

packet = IP(dst="138.201.16.225")/UDP(dport=123,sport=50000)/NTP(version=4)

print("Request")
print('='*40)
packet.show()

print("Response")
print('='*40)
resp = sr1(packet)
resp.show()

ntp = resp[2]
print(ntp.sent)