#!/bin/bash
#
# Instala el repositorio APT Ceibal y ejecuta por primera vez ceibal-update 
# para instalar las actualizaciones existentes.
#

# El script aborta si cualquiera de los comandos falla. 
set -e

unset CDPATH

if [[ $UID -ne 0 ]]; then 
    echo "El script debe ser ejecutado como root." >&2
    exit 1;
fi

mkdir -p /var/spool/ceibal-update-check/

# Copiar scripts de actualizacion
cp ceibal-update /usr/sbin/
chmod 755 /usr/sbin/ceibal-update

cp ceibal-update-check /usr/sbin/
chmod 755 /usr/sbin/ceibal-update-check

# Configurar opciones especiales del repositorio
mkdir -p /etc/apt/preferences.d/
cp 90ceibal.pref /etc/apt/preferences.d/
chmod 644 /etc/apt/preferences.d/90ceibal.pref

# Crear directorio para pedidos de actualizacion creados
# por otros paquetes
mkdir -p /etc/ceibal-update.d/
		
# Instalar clave GPG del repositorio
cat /usr/share/doc/ceibal-repo-update/apt-ceibal.gpg.key | apt-key add -

# Configurar el repositorio
RELEASE=`lsb_release -c -s`
case $RELEASE in
utopic|trusty)
    CODENAME=tero
    ;;
precise)
    CODENAME=tatu
    ;;
esac

if [ "${CODENAME}" != "" ]; then
    cp ceibal.list /etc/apt/sources.list.d/ceibal.list
    sed -i -e "s,//CODENAME//,${CODENAME}," "/etc/apt/sources.list.d/ceibal.list"
else
    logger "No se pudo determinar el nombre de la distribucion: ${RELEASE}"
    exit 1
fi

# Copiar script de cron para actualizaciones
cp debian/ceibal-repo-update.cron.d /etc/cron.d/
