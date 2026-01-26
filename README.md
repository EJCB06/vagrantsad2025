# Práctica 5: Instalación y Configuración de Cortafuegos (IPTables)

Este repositorio contiene la infraestructura como código (IaC) necesaria para desplegar un entorno de red completo con **DMZ, LAN y WAN**, configurado mediante **Vagrant** y **VirtualBox**.

El objetivo principal es implementar un cortafuegos en la máquina `gw` (Gateway) utilizando `iptables` para filtrar el tráfico entre las distintas zonas de red según una política de seguridad restrictiva.

## 📋 Requisitos Previos

Para desplegar este entorno, necesitas tener instalado el siguiente software en tu máquina anfitriona:

* [Git](https://git-scm.com/)
* [VirtualBox](https://www.virtualbox.org/)
* [Vagrant](https://www.vagrantup.com/)

## 🚀 Instrucciones de Despliegue

Sigue estos pasos para poner en marcha el laboratorio:

1.  **Clonar el repositorio:**
    Abre una terminal y descarga los archivos del proyecto.
    ```bash
    git clone [https://github.com/EJCB06/vagrantsad2025.git](https://github.com/EJCB06/vagrantsad2025.git)
    ```

2.  **Acceder al directorio:**
    ```bash
    cd vagrantsad2025
    ```

3.  **Iniciar el entorno (Despliegue):**
    Ejecuta el siguiente comando para descargar las imágenes (boxes) y configurar las máquinas virtuales automáticamente.
    ```bash
    vagrant up
    ```
    *Nota: Este proceso puede tardar unos minutos dependiendo de tu conexión a internet y la potencia de tu equipo.*

## Pruebas de Funcionamiento

Una vez desplegado, puedes acceder a las máquinas para verificar las reglas del cortafuegos.

### Acceso a las máquinas
Para entrar en la máquina principal (Gateway), usa:
```bash
vagrant ssh gw
```

# Realización de pruebas
