import socket


class Scanner:
    def __init__(self, target_ip, timeout=1.0):
        self.target_ip = target_ip
        # Sans timeout, un port filtré (firewall en DROP) bloque très longtemps
        self.timeout = timeout

    def scan_port(self, port):
        # "with" ferme le socket automatiquement, même en cas d'erreur
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
            sock.settimeout(self.timeout)
            # connect_ex renvoie 0 si le port est ouvert, sinon un errno
            res = sock.connect_ex((self.target_ip, port))
        return res == 0


def main():
    scanner = Scanner("127.0.0.1")
    for port in (443, 801):
        etat = "open" if scanner.scan_port(port) else "closed"
        print(f"{scanner.target_ip}:{port} {etat}")


if __name__ == "__main__":
    main()
