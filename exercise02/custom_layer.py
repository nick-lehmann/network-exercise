from scapy import packet
from scapy.fields import ByteField, ShortField
from scapy.layers.l2 import Ether
from scapy.layers.inet import TCP


class Custom(packet):
    name = "Custom"
    fields_desc = [
        ByteField('version', 1),
        ShortField('length', 0),
    ]


p = Ether(type=0x1234) / Custom() / "My message"
