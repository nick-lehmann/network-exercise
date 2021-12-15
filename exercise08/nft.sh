# Alle eingehenden ICMP-Pakete sollen verworfen werden
chain input {
  ip protocol icmp drop;
  ip protocol icmp icmp type echo-request drop;
}

# Eingehende Pakete sollen nur akzeptiert werden, sofern diese zu lokal initiierten Verbindungen gehören.
chain input {
  ct state established,related accept;
}

# SSH-Verbindungen auf Port 22 sollen eingehend akzeptiert werden.
chain input {
  ip protocol tcp dport ssh accept;
}

# Nur Pakete an das Netz 192.168.2.0/24 sollen weitergeleitet werden.
chain forward {

}

# Falls ein ausgehendes ICMP-Paket den Netzwerkstack durchläuft, soll ein Eintrag in einer Log-Datei angelegt werden, der diese Tatsache vermerkt.