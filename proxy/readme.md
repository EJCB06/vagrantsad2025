# Memoria de Pruebas y Evidencias - Práctica Squid Proxy + Firewall
En esta práctica hemos creado un proxy funcional para la red que teniamos y aquí voy a explicar las comprobaciones realizadas en la infraestructura de red, el cortafuegos y el servidor proxy Squid, incluyendo la configuración avanzada de listas negras.


## 1. Verificación de Conectividad en la DMZ
Se han ejecutado los scripts de comprobación automática en los servidores de la DMZ para ver que tienen salida a Internet exclusivamente a través del proxy configurado.

### Captura 1: Servidor Web (www)

![](images/SAD%20SQUIRT%20CAP2.png)

Descripción: Ejecución del script servidores.sh en la máquina www.

Todos los tests han pasado correctamente ([OK]). Esto confirma que:

- La máquina tiene configuradas las variables de entorno del proxy.  
- El firewall del Gateway permite el tráfico desde www hacia el Proxy.  
- El Proxy permite la salida a Internet de esta máquina sin solicitar autenticación (lista blanca de DMZ).


### Captura 2: Proveedor de Identidad (idp)

![](images/SAD%20SQUIRT%20CAP1.png)

Descripción: Ejecución del script servidores.sh en la máquina idp.

Al igual que en el servidor web, todos los tests son exitosos, confirmando la correcta conectividad de toda la subred DMZ a través del proxy.


## 2. Configuración Avanzada: Listas Negras (Blacklist)
Se ha implementado el bloqueo de millones de sitios maliciosos o inapropiados utilizando una lista negra pública (blackweb.txt) aplicada a la red LAN.

### Captura 3: Configuración de Squid (proxy)

![](images/SAD%20SQUIRT%20CAP4.png)

Descripción: Captura del fichero de configuración /etc/squid/conf.d/lan.conf.

Se demuestra el orden correcto de las reglas ACL. La regla de denegación (http_access deny blackweb) se aplica antes que la regla que permite el acceso general a la LAN (http_access allow redLan...). Esto asegura que si un dominio está en la lista negra, será bloqueado inmediatamente.

### Captura 4: Prueba Funcional Manual (empleado)

![](images/SAD%20SQUIRT%20CAP5.png)

Descripción: Pruebas manuales con curl desde un cliente LAN autenticado para verificar el filtrado.

Prueba de Acceso Permitido: El comando hacia iescelia.org devuelve un HTTP/1.1 200 Connection established, confirmando que la navegación legítima funciona.

Prueba de Bloqueo: El comando hacia un dominio presente en la lista negra devuelve un HTTP/1.1 403 Forbidden. El encabezado X-Squid-Error: ERR_ACCESS_DENIED confirma que ha sido Squid quien ha realizado el bloqueo exitosamente.

## 3. Pruebas Automáticas en Clientes LAN
Se ha ejecutado el script de validación en la máquina cliente para comprobar las diferentes políticas de acceso de la LAN.

### Captura 5: Script de Usuarios (empleado) y Explicación de Resultado

![](images/SAD%20SQUIRT%20CAP3.png)

Descripción: Ejecución del script usuarios-lan.sh.

Test 1 (Autenticación): [OK]. El proxy solicita credenciales (407) si no se proporcionan.

Test 3 y 4 (Filtros): [OK]. Los bloqueos de redes sociales y expresiones prohibidas devuelven 403 Forbidden correctamente.

Test 2 (Usuario Correcto): Marcado como [FALLO] con Código 301.

Explicación del Código 301: Este resultado no indica un fallo en la configuración del proxy ni del firewall. El código 301 Moved Permanently indica que el proxy permitió la conexión correctamente, pero el servidor web de destino (iescelia.org) respondió con una redirección hacia su versión HTTPS.

El script de prueba automatizado es estricto y espera únicamente un código 200 OK. Al recibir un 301, lo marca como fallo, aunque funcionalmente la conexión fue exitosa (no fue bloqueada con un 403).
