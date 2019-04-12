#!/usr/bin/env bash


list_installable_packages() {
    cat <<EOF
Syntax:

    sysutils install [package] [args]

Example:

    sysutils install php7deb

Available Packages:
EOF
    IFS="|"
    INSTALLDIR=$1
    APPS=("Package")
    DESCRIPTIONS=("Description")
    STATES=("Installed?")

    for FILE in ${INSTALLDIR}/*.sh;
    do
        if [ -d ${FILE} ]; then
            continue
        fi

        APP=$(head ${FILE} -n2 | tail -n1 | sed 's/#//' | xargs )
        DESCRIPTION=$(head ${FILE} -n3 | tail -n1 | sed 's/#//' | xargs )

        APPS=(${APPS[@]} ${APP})
        DESCRIPTIONS=(${DESCRIPTIONS[@]} "${DESCRIPTION}")

        if [ ! -z $(grep ${APP} ${PACKAGEINSTALLDIR}/history) ]; then
            STATES=(${STATES[@]} "Installed")
        else
            STATES=(${STATES[@]} "-")
        fi
    done


    APPCOUNT=${#APPS}
    MAXLEN=0

    for APP in ${APPS[@]}
    do
        SIZE=${#APP}
        if [ ${SIZE} -gt ${MAXLEN} ]; then
            MAXLEN=${SIZE}
        fi
    done

    COUNTER=0
    COLUMNLEN=$((${MAXLEN} + 2 ))

    for APP in ${APPS[@]}
    do
        DESC=${DESCRIPTIONS[${COUNTER}]}
        STATE=${STATES[${COUNTER}]}

        printf "\n%-15s %-${COLUMNLEN}s  %-100s" ${STATE} ${APP} ${DESC}
        COUNTER=$((${COUNTER} + 1))
    done

    echo ""
    echo ""

}

install_package() {

    PACKAGE=$1
    INSTALLSCRIPT=${PACKAGEINSTALLDIR}/${PACKAGE}.sh

    if [ -z ${PACKAGE} ]; then
        list_installable_packages ${PACKAGEINSTALLDIR}
        exit 1
    fi

    if [ ! -f ${INSTALLSCRIPT} ]; then
        list_installable_packages ${PACKAGEINSTALLDIR}
        exit 1
    fi

    source ${INSTALLSCRIPT}
    run_installer
    printf "\n${PACKAGE} >> ${PACKAGEINSTALLDIR}/history
}