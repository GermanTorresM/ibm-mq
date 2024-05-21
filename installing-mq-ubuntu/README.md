# Ejecutando el script bash de instalación de Ubuntu

Este script bash se utiliza para instalar una instancia MQ Advanced for Developers localmente en un servidor Ubuntu.

## Qué hace el script

1. Descarga IBM MQ Advanced for Developers.
2. Instala IBM MQ e imprime la versión instalada.
3. Crea e inicia un gestor de colas.
4. Crea objetos MQ para que los use el gestor de colas.
5. Autoriza a los miembros del grupo "mqclient" a conectarse al gestor de colas.

## Creación de User/group

As mentioned in the tutorial, before using the script, you will need to create a new user account "app" and a new group "mqclient". Commands should look like this:

```bash
sudo addgroup mqclient
sudo adduser app
sudo adduser app mqclient
```

## Get and run the script

Download the script (e.g. with a wget of the raw file URL).
Once this is done, run the command

```bash
chmod 755 mq-ubuntu-install.sh
```

The script can now be executed with

```bash
sudo ./mq-ubuntu-install.sh
```
