#!/bin/bash

# Server files
server_dir=$1

if [ -z $server_dir ]; then
    echo "server_dir not provided!"
    exit 1
fi

bepinex_url=https://v-rising.thunderstore.io/package/BepInEx/BepInExPack_V_Rising/
current_v="$(find ${server_dir} -maxdepth 1 -name "BepInEx-*" | cut -d '-' -f2)"
thunderstore_data="$(curl -s -X GET https://thunderstore.io/c/v-rising/api/v1/package/b86fcaaf-297a-45c8-82a0-fcbd7806fdc4/ -H "accept: application/json")"
latest_v="$(echo ${thunderstore_data} | jq -r '.versions[0].version_number')"

if [ -z "${latest_v}" ] && [ -z "${current_v}" ]; then
    echo "--- Can't get latest version of BepInEx for V Rising! ---"
    echo "--- Please try to run the Container without BepInEx for V Rising! ---"
    exit 1
fi

if [ -f ${server_dir}/BepInEx.zip ]; then
    rm -rf ${server_dir}/BepInEx.zip
fi

if [ -f ${server_dir}/doorstop_config.ini ]; then
    sed -i "/enabled=false/c\enabled=true" ${server_dir}/doorstop_config.ini
fi

echo "--- BepInEx for V Rising Version Check ---"
echo
echo "--- ${bepinex_url} ---"
echo

bepinex_download_url="$(echo ${thunderstore_data} | jq -r '.versions[0].download_url')"

if [ -z "${current_v}" ]; then
    echo "--- BepInEx for V Rising not found, downloading and installing v${latest_v}..."

    cd ${server_dir}
    rm -rf ${server_dir}/BepInEx-*

    if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${server_dir}/BepInEx.zip --user-agent=Mozilla --content-disposition -E -c "${bepinex_download_url}" ; then
        echo "---Successfully downloaded BepInEx for V Rising v${latest_v}---"
    else
        echo "---Something went wrong, can't download BepInEx for V Rising v${latest_v}, putting container into sleep mode!---"
        exit 1
    fi

    mkdir -p /tmp/BepInEx
    unzip -o ${server_dir}/BepInEx.zip -d /tmp/BepInEx

    if [ $? -eq 0 ];then
        touch ${server_dir}/BepInEx-${latest_v}
        cp -rf /tmp/BepInEx/BepInEx*/* ${server_dir}/
        cp /tmp/BepInEx/README* ${server_dir}/README_BepInEx_for_VRising.txt
        rm -rf ${server_dir}/BepInEx.zip /tmp/BepInEx
    else
        echo "---Unable to unzip BepInEx archive! Putting container into sleep mode!---"
        exit 1
    fi

elif [ "$current_v" != "${latest_v}" ]; then
    echo "---Version missmatch, BepInEx v$current_v installed, downloading and installing v${latest_v}...---"

    cd ${server_dir}
    rm -rf ${server_dir}/BepInEx-$current_v

    mkdir /tmp/Backup
    cp -R ${server_dir}/BepInEx/config /tmp/Backup/

    if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${server_dir}/BepInEx.zip --user-agent=Mozilla --content-disposition -E -c "${bepinex_download_url}" ; then
        echo "---Successfully downloaded BepInEx for V Rising v${latest_v}---"
    else
        echo "---Something went wrong, can't download BepInEx for V Rising v${latest_v}, putting container into sleep mode!---"
        exit 1
    fi

    unzip -o ${server_dir}/BepInEx.zip -d /tmp/BepInEx 
    
    if [ $? -eq 0 ];then
        cp -rf /tmp/BepInEx/BepInEx*/* ${server_dir}/
        cp /tmp/BepInEx/README* ${server_dir}/README_BepInEx_for_VRising.txt
        touch ${server_dir}/BepInEx-${latest_v}
        cp -R /tmp/Backup/config ${server_dir}/BepInEx/
        rm -rf ${server_dir}/BepInEx.zip /tmp/BepInEx /tmp/Backup
    else
        echo "---Unable to unzip BepInEx archive! Putting container into sleep mode!---"
        exit 1
    fi
elif [ "${current_v}" == "${latest_v}" ]; then
    echo "---BepInEx v$current_v up-to-date---"
fi