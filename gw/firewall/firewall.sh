#!/bin/bash
set -ex

# Activar I p forwarding
sysctl -w net.ipv4.ip_forward=1

# Limpiar reglas previas
iptables -F
iptables -t nat -F
iptables -Z
iptables -t nat -Z

# ANTI-LOCK rule: Permitir ssh através de ETH0 para acceder con vagrant
iptables -A INPUT -i eth0 -p tcp --dport 22 -j ACCEPT
# todo lo que entra por la eth0, que va al puerto 22, lo aceptamos
iptables -A OUTPUT -o eth0 -p tcp --sport 22 -j ACCEPT
# todo lo que sale por la eth0, que va al puerto 22, lo aceptamos

# POLÍTICAS POR DEFECTO
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

###########################
# Reglas de protección local
###########################
# L1. Permitir tráfico de LoopBack
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT 

# L2. Permitir ping a cualquier máquina interna o externa
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT

# L3. Permitir que me hagan ping desde LAN y DMZ
iptables -A INPUT -i eth2 -s 172.1.2.0/24 -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -i eth3 -s 172.2.2.0/24 -p icmp --icmp-type echo-request -j ACCEPT

iptables -A OUTPUT -o eth2 -s 172.1.2.1 -p icmp --icmp-type echo-reply -j ACCEPT
iptables -A OUTPUT -o eth3 -s 172.2.2.1 -p icmp --icmp-type echo-reply -j ACCEPT

# L4. Permitir consultas DNS
iptables -A OUTPUT -o eth0 -p udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -i eth0 -p udp --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# L5. Permitir http/https para actualizar y navegar
iptables -A OUTPUT -o eth0 -p tcp --dport 80 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --sport 80 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

iptables -A OUTPUT -o eth0 -p tcp --dport 443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --sport 443 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# L6. Permitir acceso ssh solo desde admin pc
iptables -A INPUT -i eth3 -s 172.2.2.10 -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth3 -d 172.2.2.10 -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT


############################
# Reglas de protección de red
############################

# R1. Se debe hacer NAT del tráfico saliente LAN
iptables -t nat -A POSTROUTING -s 172.2.2.0/24 -o eth0 -j MASQUERADE
                                                        #usamos MASQUERADE porque solo hay salida sino -j SNAT --to IP
# R4. Permitir salir tráfico de la LAMP
iptables -A FORWARD -i eth3 -o eth0 -s 172.2.2.0/24 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o eth3 -d 172.2.2.0/24 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT



########Logs para depurar
iptables -A INPUT -j LOG --log-prefix "EJCB-INPUT: "
iptables -A OUTPUT -j LOG --log-prefix "EJCB-OUTPUT: "
iptables -A FORWARD -j LOG --log-prefix "EJCB-FORWARD: " -o eth0 -s 172.