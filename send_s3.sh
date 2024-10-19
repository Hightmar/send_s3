#!/bin/bash

_S3_BUCKET=${1}
_S3_ENDPOINT=${2}
_S3_FOLDER=${3}
_LOCATION=${4}
_S3_PROFILE=${5}
_SEARCH=${6}

if [ -z "${_S3_BUCKET}" ]; then
    echo "Argument 1 (bucket) manquant. Merci de l'ajouter"
    exit 3
fi

if [ -z "${_S3_ENDPOINT}" ]; then
    echo "Argument 2 (endpoint) manquant. Merci de l'ajouter"
    exit 3
fi

if [ -z "${_S3_FOLDER}" ]; then
    echo "Argument 3 (bucket folder) manquant. Merci de l'ajouter"
    exit 3
fi

if [ -z "${_LOCATION}" ]; then
    echo "Argument 4 (location) manquant. Merci de l'ajouter"
    exit 3
fi

if [ -z "${_S3_PROFILE}" ]; then
    echo "Argument 5 (S3 profil) manquant. Merci de l'ajouter"
    exit 3
fi

if [ -z "${_SEARCH}" ]; then
    echo "Argument 6 (Terme à chercher) manquant. Merci de l'ajouter"
    exit 3
fi

echo "################################ Variables utilisees ################################"
echo ""
echo "_S3_BUCKET    : ${_S3_BUCKET}"
echo "_S3_ENDPOINT  : ${_S3_ENDPOINT}"
echo "_S3_FOLDER    : ${_S3_FOLDER}"
echo "_LOCATION     : ${_LOCATION}"
echo "_S3_PROFILE   : ${_S3_PROFILE}"
echo "_SEARCH       : ${_SEARCH}"
echo ""
echo "#####################################################################################"

_FOLDER_WAIT="${_LOCATION}/work/wait/"
_FOLDER_DONE="${_LOCATION}/work/done/"
_ERROR_COUNT=0

mapfile -t fichiers < <(find "${_FOLDER_WAIT}" -maxdepth 1 -type f -name "${_SEARCH}[_.]*")

if [ -z "${fichiers[0]}" ]; then
    echo "Aucun fichier a envoyer"
    exit 0
fi

_EXE_NAME="aws --endpoint=${_S3_ENDPOINT}"

for ((i = 0; i < "${#fichiers[@]}"; i++)); do
    x=$((i + 1))

    _EXE_PARM="s3 cp ${fichiers[i]} s3://${_S3_BUCKET}/${_S3_FOLDER}/ --profile ${_S3_PROFILE} --no-verify-ssl --no-progress"
    ${_EXE_NAME} ${_EXE_PARM}

    _RESULT=$?

    if [ "${_RESULT}" -eq 0 ]; then
        mv "${fichiers[i]}" "${_FOLDER_DONE}"/
        _FILENAME=$(basename "${fichiers[i]}")
        echo "${x}/${#fichiers[@]}- Fichier ${_FILENAME} envoye sur le S3 et deplace dans /work/done"
    else
        _ERROR_COUNT=$((_ERROR_COUNT + 1))
        _FILENAME=$(basename "${fichiers[i]}")
        echo "${x}/${#fichiers[@]}- ERREUR :  Fichier ${_FILENAME} non envoye et non deplace dans /work/done."
    fi
done

if [ "${_ERROR_COUNT}" -gt 0 ]; then
    echo "ERREUR detectee, voir outputs"
    exit 3
fi
