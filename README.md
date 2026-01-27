# Práctica 5: Instalación y Configuración de Cortafuegos (IPTables)

Este repositorio contiene la infraestructura como código (IaC) necesaria para desplegar un entorno de red completo con **DMZ, LAN y WAN**, configurado mediante **Vagrant**.

El objetivo principal es implementar un cortafuegos en la máquina `gw` (Gateway) utilizando `iptables` para filtrar el tráfico entre las distintas zonas de red según una política de seguridad restrictiva.

## Requisitos Previos

Para desplegar este entorno, necesitas tener instalado el siguiente software en tu máquina anfitriona:

* [Git](https://git-scm.com/)
* [VirtualBox](https://www.virtualbox.org/)
* [Vagrant](https://www.vagrantup.com/)

*No es necsario pero si tu máquina anfitrión es windows puedes instalar WSL*

## Instrucciones de Despliegue

Sigue estos pasos para poner en marcha el laboratorio:

1.  **Clonar el repositorio:**
    Abre una terminal y descarga los archivos del proyecto.
    ```
    git clone [https://github.com/EJCB06/vagrantsad2025.git](https://github.com/EJCB06/vagrantsad2025.git)
    ```

/*Perdón Pablo por quedarme con los creditos de la práctica*/

2.  **Acceder al directorio:**
    ```
    cd vagrantsad2025
    ```

3.  **Iniciar el entorno (Despliegue):**
    Ejecutamos el siguiente comando para descargar las imágenes (boxes) y configurar las máquinas virtuales automáticamente.
    ```
    vagrant up
    ```
    *Nota: Este proceso puede tardar unos minutos dependiendo de nuestra conexión a internet y la potencia de nuestro equipo.*

## Pruebas de Funcionamiento

Una vez desplegado, puedes acceder a las máquinas para verificar las reglas del cortafuegos.

### Acceso a las máquinas
Para entrar en la máquina principal (Gateway), usaremos:
```
vagrant ssh gw
```

# Realización de pruebas
Estas son las pruebas que hemos realizado, para saber que nuestras reglas creadas con `iptables` son efectivas y funcionan correctamente.

· Lo primero es ver que la ejecución del script no da fallos al ejecutarse.
![](images/SAD%20script%20correcto%20funcionamiento.png)

Como podemos comprobar nuestro script se ejecuta sin problema alguno

· Ahora vamos con las pruebas de la LAN, tanto en la máquina adminpc como en la de empleado ya que tienen diferentes reglas.
![](images/SAD%20prueba%20adminpc.png)

Voy a explicar un poco lo que vemos en la imagen, como podemos ver al ejecutar las pruebas, podemos ver que tenemos conectividad a internet por el ping al 8.8.8.8, podemos ver que nuestro servidor DMZ es accesible y podemos ver que no hay problema con acceder mediante ssh a las máquinas, por último podemos ver que tenemos conexión por HTTP.

![](images/SAD%20prueba%20empleado.png)

Cuando ejecutamos el mismo script de pruebas en nuestra máquina empleado podemos ver que hay muchas similitudes, pero también hay algunas diferencias. Por ejemplo, tenemos acceso a internet, conexión a la zona DMZ y podemos navegar mediante HTTP, pero el ssh a las otras máquinas no podemos hacerlo, esto es bueno porque así podemos probar que nuestro firewall.sh está haciendo bien las cosas.

· Ahora vamos a comprobar que todo en nuestra zona DMZ esta correcto.
![](images/SAD%20dmz.png)

Al lanzar el script de de testeo, podemos ver que si tenemos HTTP y HTTPS, no encuentra el paquete dig por falta de instalación (perdón Pablo), pero lo resuelve con nslookup es decir que todo está bien y podemos ver que si resuelve consultas NTP, es decir que nuestro firewall.sh ha cumplido su función.