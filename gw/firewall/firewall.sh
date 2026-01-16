#!/bin/bash
set -ex

cat << EOF
${G}##+               _-_               +#
 #|   ___       +--   --+       ___   |
 #|      C E L I A ${Y}###${G} V I Ñ A S      |
 #|    +  _______   ${Y}|+|${G}   _______  +    |
 #|    #  #######   ${Y}|+|${G}   #######  #    |
 #|    #       ${Y}#|+++++++++|#${G}       #    |
 #|  S #            ${C}+ | +${G}            #    |
 # \   #            ${C}  |  ${G}            # \  |
 #  \ C |           ${C}__|__${G}           | P \ |
 #   \ I #     __--'${C}  V  ${G}'--__     # O   \|
 #    \ E     /       ${R}---${G}       \    / R    |
 #     \ N   |        ${R}|+|${G}        |  / T     |
 #      \ T  |    ${R}|+++ +++|${G}    | / U      |
 #       \ I |        ${R}|+|${G}        |/ S       |
 #        \ A \       ${R}|_|${G}       //          |
 #         \   \______${C} . ${G}______/ /           |
 #          \ -       ${C}/ \ ${G}      - /            |
 #           \       ${C} | ${G}       /             |
 #            \ O    ${C} | ${G}    B /              |
 #             \ M   ${C} | ${G}   U /               |
 #              \ N  ${C} v ${G}  S /                |
 #               \     I     /                 |
 #                \         /                  |
 #                 \       /                   |
 #                  \____ /${Z}

EOF

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
#Reglas de protección local
###########################
# Permitir tráfico de LoopBack



############################
#Reglas de protección de red
############################

########Logs para depurar
iptables -A INPUT -j LOG --log-prefix "EJCB-INPUT: "
iptables -A OUTPUT -j LOG --log-prefix "EJCB-OUTPUT: "
iptables -A FORWARD -j LOG --log-prefix "EJCB-FORWARD: "