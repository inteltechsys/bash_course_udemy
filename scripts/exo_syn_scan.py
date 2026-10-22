
from scapy.all import sr1, IP, TCP

def simple_port_scan(target, port):
    packet = IP(dst=target)/TCP(dport=port, flags="S")
    response = sr1(packet, timeout=1, verbose=0)
    if response and response.haslayer(TCP) and response[TCP].flags == 18:
        print(f"Port {port} is open on {target}")
    else:
        print(f"Port {port} is closed on {target}" )


simple_port_scan("192.168.1.1", 443)

