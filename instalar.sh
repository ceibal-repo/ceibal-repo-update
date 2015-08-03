#!/bin/bash
#
# Instala el repositorio APT Ceibal y ejecuta por primera vez ceibal-update 
# para instalar las actualizaciones existentes.
#

unset CDPATH

if [[ $UID -ne 0 ]]; then 
    echo "El script debe ser ejecutado como root." >&2
    exit 1;
fi

PACKAGE=ceibal-repo-update.deb

SOURCE_DIR=$(mktemp --tmpdir -d "ceibal-update-XXXXXX")
cd "${SOURCE_DIR}"

/usr/bin/wget "http://apt.ceibal.edu.uy/${PACKAGE}"
if [[ "$?" -ne 0 ]] || [[ ! -f ${PACKAGE} ]]; then
    echo "Error al bajar ${PACKAGE}." >&2
    exit 1
fi

/usr/bin/dpkg -i "${PACKAGE}"
if [[ "$?" -ne 0 ]]; then
    echo "Error al instalar ${PACKAGE}." >&2
    exit 1
fi

/bin/rm "${PACKAGE}"

# Ejecutar ceibal-update por primera vez.
/usr/sbin/ceibal-update
