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

    for FILE in ${INSTALLDIR}/*;
    do
        if [ -d ${FILE} ]; then
            continue
        fi

        APP=$(head ${FILE} -n2 | tail -n1 | sed 's/#//' | xargs )
        DESCRIPTION=$(head ${FILE} -n3 | tail -n1 | sed 's/#//' | xargs )

        APPS=(${APPS[@]} ${APP})
        DESCRIPTIONS=(${DESCRIPTIONS[@]} "${DESCRIPTION}")

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
        printf "\n%-${COLUMNLEN}s  %-100s" ${APP} ${DESC}
        COUNTER=$((${COUNTER} + 1))
    done

    echo ""
    echo ""

}

install_package() {

    PACKAGEINSTALLDIR=$1
    PACKAGE=$2
    echo "Package=${PACKAGE}"
    echo "Package Install directory: ${PACKAGEINSTALLDIR}"

    INSTALLSCRIPT=${PACKAGEINSTALLDIR}/${PACKAGE}.sh

    if [ -z ${PACKAGE} ]; then
        list_installable_packages ${PACKAGEINSTALLDIR}
        exit 1
    fi

    if [ ! -f ${INSTALLSCRIPT} ]; then
        list_installable_packages ${PACKAGEINSTALLDIR}
        exit 1
    fi


    [ -z $1 ] && error_out "You must specify a package to install"

    case $1 in
        'python3-deb')
            source ${SCRIPTSDIR}/install-python-36.sh
            install_python_36
            ;;
        'pyrpg')
            install_rpg
            ;;
        'composer')
            install_composer
            ;;
        'bacula-dir')
            install_bacula
            ;;
        'bacula-fd')
            install_bacula_fd
            ;;
        *)
            error_out "Package $1 is not found."
            ;;
    esac
}