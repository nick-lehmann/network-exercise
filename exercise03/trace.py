from scapy.all import *
from scapy.layers.inet import IP, ICMP, icmptypes
import logging
logging.getLogger("scapy").setLevel(logging.CRITICAL)


def check_hops(addr: str, max_hops=20) -> int:
    start, end = 1, max_hops

    while start <= end:
        middle = (start + end) // 2
        print(f"Trying to reach host with {middle} hops ({start}-{end})")

        ans, _ = sr(IP(dst=addr, ttl=middle)/ICMP())
        icmp = ans[0].answer[1]
        reply_type = icmptypes[icmp.type]

        if reply_type == 'echo-reply':
            print("Success")
            end = middle - 1
        elif reply_type == 'time-exceeded':
            print("Failure")
            start = middle + 1
        else:
            raise ValueError("Houston, we got a problem")

        print('-' * 20)

    return start


addr = "8.8.8.8"
hops = check_hops(addr)
print(f"We can reach {addr} with {hops} hops")
