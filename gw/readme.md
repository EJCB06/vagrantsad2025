# Despliegue de VPN Corporativa con OpenVPN, LDAP y Cortafuegos


Este repositorio documenta la implementación de una infraestructura de acceso remoto seguro utilizando **OpenVPN**. El proyecto simula un entorno empresarial (Dominio: `ecueber.org`) donde los empleados pueden conectarse de forma segura a la red interna y acceder a servicios en la DMZ, validando sus credenciales contra un directorio centralizado (LDAP).


## Tecnologías usadas

![OpenVPN](https://img.shields.io/badge/OpenVPN-EA7E20?style=for-the-badge&logo=openvpn&logoColor=white)
![Vagrant](https://img.shields.io/badge/Vagrant-1563FF?style=for-the-badge&logo=vagrant&logoColor=white)
![OpenLDAP](https://img.shields.io/badge/OpenLDAP-324F6F?style=for-the-badge&logo=openldap&logoColor=white)
![Easy-RSA](https://img.shields.io/badge/Easy--RSA-000000?style=for-the-badge&logo=letsencrypt&logoColor=white)
![IPTables](https://img.shields.io/badge/IPTables-E34F26?style=for-the-badge&logo=linux&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)

## Escenario y Topología

Se ha desplegado una arquitectura de red virtualizada con las siguientes características:
* **Red WAN:** Acceso simulado a Internet.
* **Red LAN (172.2.2.0/24):** Red interna protegida.
* **DMZ (172.1.2.0/24):** Zona desmilitarizada para servicios públicos.

## Infraestructura y Configuración

El servidor OpenVPN actúa como Gateway y Autoridad de Certificación (CA). Se han configurado claves RSA de 2048 bits y autenticación HMAC (TLS-Crypt) para proteger el túnel. La autenticación de usuarios se delega a un servidor **LDAP** externo (`172.2.2.2`).

El cortafuegos **IPTables** ha sido configurado para permitir el tráfico VPN (Puerto 1194 UDP), el enrutamiento del túnel `tun0` y el tráfico ICMP (Ping) para diagnóstico.


## Evidencias de Funcionamiento (Rúbrica)

A continuación se presentan las pruebas requeridas para validar el despliegue.

### 1. Estado del Servicio (GW)
Comprobación de que el servicio `openvpn-server@server` está activo y corriendo en el Gateway.

![](openvpn/images/SAD%20OPENVPN.png)


### 2. Logs de Conexión Exitosa
Registro del servidor en el momento exacto en que el cliente `edwin` establece la conexión, mostrando la secuencia de inicialización completa.

![](openvpn/images/SAD%20OPENVPN%20CAP%202.png)

![](openvpn/images/SAD%20OPENVPN%20CAP%203.png)

![](openvpn/images/SAD%20OPENVPN%20CAP%204.png)


### 3. Pruebas de Conectividad (Ping y Curl)
Verificación de acceso a los recursos internos desde el cliente VPN:
1.  **Ping a la LAN:** Conectividad ICMP con el servidor IDP (`172.2.2.2`).
2.  **Curl a la DMZ:** Acceso HTTP al servidor web (`172.1.2.3`).

![](openvpn/images/SAD%20OPENVPN%20CAP%206.png)

![](openvpn/images/SAD%20OPENVPN%20CAP%205.png)


### 4. Ampliación: Acceso con windows
Donde podemos ver que tenemos tabién conexión desde nuestra máquina windows, siempre  cuando estemos en la misma red interna, donde están las demás.

![](openvpn/images/SAD%20OPENVPN%20CAP%207.1.png)

![](openvpn/images/SAD%20OPENVPN%20CAP%207.png)


### Fichero de Configuración de Cliente (.ovpn)
Contenido generado para el usuario `edwin`, que incluye certificados, claves y configuración de conexión, aún asi también esta el fichero en el repositorio.

<details>
<summary><b>Haz clic para ver el contenido de edwin.ovpn</b></summary>

```bash
# Especificamos que somos el cliente
client

# Dirección del servidor, puerto y protocolo
remote 203.0.113.254 1194
;remote my-server-2 1194
proto udp
dev tun

# Activa si tienes varios remotes y quieres balanceo de carga
;remote-random

# Keep trying indefinitely to resolve the host name of the OpenVPN server.
resolv-retry infinite

# Most clients don't need to bind to a specific local port number.
nobind

# Downgrade privileges after initialization (non-Windows only)
user nobody
group nogroup

# Try to preserve some state across restarts.
persist-key
persist-tun

# Configuracion por si te conectas a traves de un proxy
;http-proxy-retry # retry on connection failures
;http-proxy [proxy server] [proxy port #]

# Silenciar avisos duplicados. Suele ocurrir mas en redes WiFi
;mute-replay-warnings

# Claves. Lo comentamos porque se adjuntan en fichero .ovpn
;ca ca.crt
;cert client.crt
;key client.key

# Comprobar la identidad del servidor
remote-cert-tls server

# If a tls-auth key is used on the server
# then every client must also have the key.
;tls-auth ta.key 1

# Cifrado
cipher AES-256-GCM
auth SHA512

# Compresion
; comp-lzo

# Set log file verbosity.
verb 3

# Silence repeating messages
;mute 20

# Configuracion extra para systemd-resolve
#script-security 2
#up /etc/openvpn/update-systemd-resolved
#down /etc/openvpn/update-systemd-resolved
#down-pre
#dhcp-option DOMAIN-ROUTE .
<ca>
-----BEGIN CERTIFICATE-----
MIIDSDCCAjCgAwIBAgIUXNujsinon9upAek6qHTnUB9uvrcwDQYJKoZIhvcNAQEL
BQAwFTETMBEGA1UEAwwKZWN1ZWJlci1DQTAeFw0yNjAyMTIxMTQ5MDRaFw0zNjAy
MTAxMTQ5MDRaMBUxEzARBgNVBAMMCmVjdWViZXItQ0EwggEiMA0GCSqGSIb3DQEB
AQUAA4IBDwAwggEKAoIBAQCwPJIlKxFSTGw98ftE8nCLpio6n+eRXnVDCZEZLPln
Aqkh0ZIbELPCOaJ+5UrZAUBGk5itRqNgNrNGo6onmtgoHMiF0tRHlpimW4RrBMMy
nEkg1eGvgJQl251iVY7xJxl7uUHREYdXfBeDO4yaYQz9o173AKY5rK3T+9gKN2+Z
ZZBNvdfS3yKh+yawq57WkTTdT0o4yP4JUEoyCvfB9+JLm5pr00TyF7NIAHvKcHxu
VCXAXn7k5hbVcGuWB961riRCq5e46Poagph5RYw+gJ+9+lh0W4sIBDtYi92CtoNz
lfFSZik+bg3eKe7ngs/OX0i99DFufMXQ4t/ILDlwHoKXAgMBAAGjgY8wgYwwDAYD
VR0TBAUwAwEB/zAdBgNVHQ4EFgQUE37wTDV6VEH3iRO5S+E1ehcYE20wUAYDVR0j
BEkwR4AUE37wTDV6VEH3iRO5S+E1ehcYE22hGaQXMBUxEzARBgNVBAMMCmVjdWVi
ZXItQ0GCFFzbo7Ip6J/bqQHpOqh051Afbr63MAsGA1UdDwQEAwIBBjANBgkqhkiG
9w0BAQsFAAOCAQEAXCI3TYN2fAubMbTOlFic1mdB7RAy6esTF1qtGwcaLp0ZtuoZ
xgm2wJf6IRT1Eh5wEwwmyhPLjFrr81Jpwu/C+bu71GcpgR8QeExYcfufdO8BKw7/
QBi4zNkJmmS8Utp7BwiLuk0NgqQOxuKtUyaafvH6Hu4GD/1y4CCo5bSzuyLMY58M
G+Qgu5FBquvKIn+dFGDTENhp4+dQDXX2+acXdkKI1ghtP7BRQXA3rtpHHl/H8zHy
fRftqSvKa/HD2S1NDMF/BrYVoPIiK9PjZRq8srFlqUZzitNOhhFEV95uidNBuWYf
6U6RMR4CKpmWCjhCuEThenG8nOTrmMYhynQ3iQ==
-----END CERTIFICATE-----
</ca>
<cert>
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            f7:61:84:50:30:84:93:76:08:03:37:df:e4:b4:99:ac
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN=ecueber-CA
        Validity
            Not Before: Feb 12 11:56:55 2026 GMT
            Not After : May 17 11:56:55 2028 GMT
        Subject: CN=edwin
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:d0:df:07:d7:32:f4:ae:14:95:53:f9:b1:c2:72:
                    51:5a:88:dc:61:61:84:43:6b:79:32:0c:7f:a4:c1:
                    d5:40:5c:9d:26:37:40:38:6d:3f:87:b2:b2:54:e1:
                    2e:90:ee:b4:31:69:90:ab:01:ff:66:cf:7b:0a:11:
                    d2:00:30:55:aa:b9:05:f7:af:1e:c1:40:9b:61:7e:
                    af:03:3c:59:ae:e7:f7:ae:f8:58:ac:20:10:32:61:
                    0f:22:df:3e:b5:d4:af:35:26:e3:ca:a8:80:d1:d2:
                    0e:6d:21:70:af:b8:1d:59:b5:97:95:77:7a:24:f8:
                    24:f2:93:40:0f:d8:10:02:aa:b0:9b:8e:3d:80:e4:
                    dd:85:fb:ed:d1:18:66:64:84:2b:c3:e5:c5:50:44:
                    0e:c0:b5:1b:00:59:f5:49:d9:27:50:94:5b:70:1f:
                    2e:5f:f4:3f:d3:2c:75:3e:8e:77:89:b1:d1:a2:8d:
                    9a:3f:de:3b:6d:de:72:cd:15:56:8b:3f:a9:7f:b9:
                    0a:ca:8e:b1:47:3d:37:a6:91:7c:bf:34:36:f4:68:
                    0f:9b:bc:97:6e:cb:46:b9:5b:3a:c6:87:a0:26:02:
                    e8:61:f1:21:f6:77:6a:3d:9b:bb:a9:58:43:0a:9a:
                    c1:c9:4a:5d:5f:b3:12:01:fc:ac:dd:30:ce:82:cd:
                    88:7f
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints:
                CA:FALSE
            X509v3 Subject Key Identifier:
                3E:76:F9:FD:79:B2:14:85:9F:8B:65:7D:49:AC:60:F3:3E:36:13:62
            X509v3 Authority Key Identifier:
                keyid:13:7E:F0:4C:35:7A:54:41:F7:89:13:B9:4B:E1:35:7A:17:18:13:6D
                DirName:/CN=ecueber-CA
                serial:5C:DB:A3:B2:29:E8:9F:DB:A9:01:E9:3A:A8:74:E7:50:1F:6E:BE:B7
            X509v3 Extended Key Usage:
                TLS Web Client Authentication
            X509v3 Key Usage:
                Digital Signature
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        93:e3:a3:9d:26:8f:ba:63:4f:97:87:be:c0:55:12:61:e2:f4:
        74:87:56:e8:11:64:2a:e4:40:3c:6c:f1:2f:41:08:ed:1e:a6:
        95:27:2d:a3:c2:1d:40:94:26:e9:b7:6d:95:93:24:1e:8e:de:
        e5:e7:86:18:2a:b3:ca:e1:61:ce:d3:d3:b2:9e:19:eb:f5:8d:
        2e:cf:4a:7e:6c:40:1f:d4:be:3a:58:a0:a2:77:ed:f8:7d:1c:
        df:39:b4:a8:b4:23:a3:98:bc:b1:68:0a:f5:66:a6:01:3f:0d:
        f7:8b:35:0d:22:a0:41:74:45:1e:9b:52:d0:78:26:f6:b7:85:
        d3:38:52:96:be:39:d0:72:a6:8e:71:f7:c1:14:06:27:9a:32:
        27:fc:55:75:e6:a5:2b:78:b0:57:2e:19:90:ae:36:d7:3d:61:
        dc:d7:c6:38:96:c4:f1:9a:1f:1e:bc:52:a0:c8:eb:dc:21:e8:
        39:05:1b:5c:fa:88:d8:c0:7d:1a:57:1d:31:22:4d:4d:3a:4e:
        be:97:60:af:2c:49:56:25:a6:db:63:4d:d7:7b:82:90:c3:d8:
        d2:e3:76:65:3e:87:a8:4f:68:ef:e0:a2:23:e5:25:67:a8:e8:
        71:44:0d:ec:f5:64:a5:20:17:55:26:8c:0d:25:c5:01:42:b6:
        89:50:b1:8b
-----BEGIN CERTIFICATE-----
MIIDUjCCAjqgAwIBAgIRAPdhhFAwhJN2CAM33+S0mawwDQYJKoZIhvcNAQELBQAw
FTETMBEGA1UEAwwKZWN1ZWJlci1DQTAeFw0yNjAyMTIxMTU2NTVaFw0yODA1MTcx
MTU2NTVaMBAxDjAMBgNVBAMMBWVkd2luMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A
MIIBCgKCAQEA0N8H1zL0rhSVU/mxwnJRWojcYWGEQ2t5Mgx/pMHVQFydJjdAOG0/
h7KyVOEukO60MWmQqwH/Zs97ChHSADBVqrkF968ewUCbYX6vAzxZruf3rvhYrCAQ
MmEPIt8+tdSvNSbjyqiA0dIObSFwr7gdWbWXlXd6JPgk8pNAD9gQAqqwm449gOTd
hfvt0RhmZIQrw+XFUEQOwLUbAFn1SdknUJRbcB8uX/Q/0yx1Po53ibHRoo2aP947
bd5yzRVWiz+pf7kKyo6xRz03ppF8vzQ29GgPm7yXbstGuVs6xoegJgLoYfEh9ndq
PZu7qVhDCprByUpdX7MSAfys3TDOgs2IfwIDAQABo4GhMIGeMAkGA1UdEwQCMAAw
HQYDVR0OBBYEFD52+f15shSFn4tlfUmsYPM+NhNiMFAGA1UdIwRJMEeAFBN+8Ew1
elRB94kTuUvhNXoXGBNtoRmkFzAVMRMwEQYDVQQDDAplY3VlYmVyLUNBghRc26Oy
Keif26kB6TqodOdQH26+tzATBgNVHSUEDDAKBggrBgEFBQcDAjALBgNVHQ8EBAMC
B4AwDQYJKoZIhvcNAQELBQADggEBAJPjo50mj7pjT5eHvsBVEmHi9HSHVugRZCrk
QDxs8S9BCO0eppUnLaPCHUCUJum3bZWTJB6O3uXnhhgqs8rhYc7T07KeGev1jS7P
Sn5sQB/UvjpYoKJ37fh9HN85tKi0I6OYvLFoCvVmpgE/DfeLNQ0ioEF0RR6bUtB4
Jva3hdM4Upa+OdBypo5x98EUBieaMif8VXXmpSt4sFcuGZCuNtc9YdzXxjiWxPGa
Hx68UqDI69wh6DkFG1z6iNjAfRpXHTEiTU06Tr6XYK8sSVYlpttjTdd7gpDD2NLj
dmU+h6hPaO/goiPlJWeo6HFEDez1ZKUgF1UmjA0lxQFCtolQsYs=
-----END CERTIFICATE-----
</cert>
<key>
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDQ3wfXMvSuFJVT
+bHCclFaiNxhYYRDa3kyDH+kwdVAXJ0mN0A4bT+HsrJU4S6Q7rQxaZCrAf9mz3sK
EdIAMFWquQX3rx7BQJthfq8DPFmu5/eu+FisIBAyYQ8i3z611K81JuPKqIDR0g5t
IXCvuB1ZtZeVd3ok+CTyk0AP2BACqrCbjj2A5N2F++3RGGZkhCvD5cVQRA7AtRsA
WfVJ2SdQlFtwHy5f9D/TLHU+jneJsdGijZo/3jtt3nLNFVaLP6l/uQrKjrFHPTem
kXy/NDb0aA+bvJduy0a5WzrGh6AmAuhh8SH2d2o9m7upWEMKmsHJSl1fsxIB/Kzd
MM6CzYh/AgMBAAECggEAZhNZJZZFdX2hrLRuZvSvRWt1KDIcDUbMp+TrzHzd1uJr
+m0t+WWKkqqF9G1H8JR3g15v0OLdCkWDf9xNoMH+W7yoae8vPIpyZScgKJipy4yZ
wuyjiRryT2yXlRc88mfKaFNlJ3lJ20CoxDR/eaCk116jgewtyTtr8xB7UkLpMCOP
9QB+2MIVaB6vlC8AdWIdguWPXlK5Tvt51j4tTUPTIyYTZZaVlH8qfZFWqoGokWuY
T8CtSukRoaYSY/HR4X3d14WADlm6yjDf+0+c9QJYkQ/LqZvW7ABebXnn8QgG6sBL
Zy20Bjegbd4hXWS983P7lUo6/eISy2gzXIW7R1iqgQKBgQD7apuZMmiCrxHYHYux
kAMvTGyeb9PDw9/tJISwxrBmXW+GLEU81EIxE05Z3s9LVGcy3oBkkINiY6Fj8SfG
pADMU0SCQFjQIxMJ8KsxJ927tJNgoHvktQUl/BdBwdHDFDsGM4/Bsb3Qi9XHFL+U
uarTbpIFrKTiwziwETdMFrTQUQKBgQDUrdvhAu2tqVJQ4/+kAn2zsLXpnocPWJ4+
oVsri/FHbqyQ4St6lcrwoD+m1lQS5MjdJgGIFIcHYLF3xnDrqyPiiKrz/8HgNveM
qn0jHA8r1eeSvSrC10IABGaOHMkccqFfOlxtP+6WvbXY/g4mwNLofkpbR4Zk2bXF
EFJ1DKDnzwKBgQCRYOvoggV8y879sNf+LNAqoX6Nfwxsvu7VKbCwp7OI/a5nX2IJ
8pLz3b4IqZYkcQHboF2NySKv2fyQ1fmyG1N60wtiZeL1N9LihI/5NJw61ggCb8o0
TZhUhpjMJU8uBpy60UXnMugXl0RegdjmHxZwfBdjwJj3pvs4lDvte5PCgQKBgH97
x7VVAAt8127NfEtfguHXJvPmpqa4RALezbuIoxRibuZZUqqkZ4VdSUpEZxj8Mrr9
MSXUyCvP9hEJzl41s8jyiya/RAOWb0TOXTxScXWhPrJi2eL5DQLdoGvHLXXz8G8Y
mJaUH/wTs5FimDD6nHHoYcHdWd3R8ncxlXu8GidZAoGBAPqJS8d8o5I+zEuFoYE8
Z+WhpAhS0fJBVc/eL0K3lqs5M3mRelf+2aXmwzDTPpuUXDLifHOEPVw99B14tTOU
1I983Kqst4IELTMFX+QzO/XGs6bsT3cMw1kQjl6kVrTE4n85Zmb12vaFiOpyfN0J
TBi8os2trfYXrR/X3WJajkKG
-----END PRIVATE KEY-----
</key>
<tls-crypt>
#
# 2048 bit OpenVPN static key
#
-----BEGIN OpenVPN Static key V1-----
a8cfcc01ea4edc2b52348ab7e98ef750
edf5d581294d86ef068751ea83c4654e
1ce89e49d7c579c85528ecb447fc9cae
1f266c3916d799c794a1ddcd1ba6e6be
ebd00397059b04b57c30cf12bf801853
84d4c80154ef731abbd6aed683d20aa2
1988eef6fca1783cbb6b3af4223a970e
bb4d79baf34580683fa3143ab290b63e
a6b17bae421eaf6fb7d806292ada466b
2d6f24b9a9a8b6ce798435b620c8a5a8
ee4198ed63c54808a1f8e655fa197002
b365f25ee085c7895494e731d600ce2a
922f4cebb84200c8624c6dab2441ff77
6924856be79731bcdb7ebe181217645a
0da0cda255ba50b9401751b893b09679
a739ac20f1edeb6ecf5afbcefd76a1ac
-----END OpenVPN Static key V1-----
</tls-crypt>
auth-user-pass
</details>
```
---
**Autor: Edwin Javier Cueva Berenguer**  
**Asignatura: Seguridad y Alta Disponibilidad**