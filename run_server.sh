#!/bin/bash

# Server files
server_dir=/mnt/vrising/server

# Save files and settings
data_dir=/mnt/vrising/data

echo "--- Update server"
/usr/bin/steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir "$server_dir" +login anonymous +app_update 1829350 validate +quit
echo "--- Update done"

# BEPINEX
export  WINEDLLOVERRIDES="winhttp=n,b"

BEPINEX_VR_TS_URL=https://v-rising.thunderstore.io/package/BepInEx/BepInExPack_V_Rising/
CUR_V="$(find ${SERVER_DIR} -maxdepth 1 -name "BepInEx-*" | cut -d '-' -f2)"
BEPINEX_VR_API_DATA="$(curl -s -X GET https://thunderstore.io/c/v-rising/api/v1/package/b86fcaaf-297a-45c8-82a0-fcbd7806fdc4/ -H "accept: application/json")"
LAT_V="$(echo ${BEPINEX_VR_API_DATA} | jq -r '.versions[0].version_number')"

if [ -z "${LAT_V}" ] && [ -z "${CUR_V}" ]; then
    echo "--- Can't get latest version of BepInEx for V Rising! ---"
    echo "--- Please try to run the Container without BepInEx for V Rising! ---"
    exit 1
fi

if [ -f ${SERVER_DIR}/BepInEx.zip ]; then
    rm -rf ${SERVER_DIR}/BepInEx.zip
fi
if [ -f ${SERVER_DIR}/doorstop_config.ini ]; then
    sed -i "/enabled=false/c\enabled=true" ${SERVER_DIR}/doorstop_config.ini
fi

echo "--- BepInEx for V Rising Version Check ---"
echo
echo "--- ${BEPINEX_VR_TS_URL} ---"
echo

BEPINEX_VR_TS_DOWNLOAD_URL="$(echo ${BEPINEX_VR_API_DATA} | jq -r '.versions[0].download_url')"

if [ -z "${CUR_V}" ]; then
    echo "---BepInEx for V Rising not found, downloading and installing v${LAT_V}...---"
    cd ${SERVER_DIR}
    rm -rf ${SERVER_DIR}/BepInEx-*
    if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${SERVER_DIR}/BepInEx.zip --user-agent=Mozilla --content-disposition -E -c "${BEPINEX_VR_TS_DOWNLOAD_URL}" ; then
        echo "---Successfully downloaded BepInEx for V Rising v${LAT_V}---"
    else
        echo "---Something went wrong, can't download BepInEx for V Rising v${LAT_V}, putting container into sleep mode!---"
        sleep infinity
    fi
    mkdir -p /tmp/BepInEx
    unzip -o ${SERVER_DIR}/BepInEx.zip -d /tmp/BepInEx
    if [ $? -eq 0 ];then
        touch ${SERVER_DIR}/BepInEx-${LAT_V}
        cp -rf /tmp/BepInEx/BepInEx*/* ${SERVER_DIR}/
        cp /tmp/BepInEx/README* ${SERVER_DIR}/README_BepInEx_for_VRising.txt
        rm -rf ${SERVER_DIR}/BepInEx.zip /tmp/BepInEx
    else
        echo "---Unable to unzip BepInEx archive! Putting container into sleep mode!---"
        sleep infinity
    fi
elif [ "$CUR_V" != "${LAT_V}" ]; then
    echo "---Version missmatch, BepInEx v$CUR_V installed, downloading and installing v${LAT_V}...---"
    cd ${SERVER_DIR}
    rm -rf ${SERVER_DIR}/BepInEx-$CUR_V
    mkdir /tmp/Backup
    cp -R ${SERVER_DIR}/BepInEx/config /tmp/Backup/
    if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${SERVER_DIR}/BepInEx.zip --user-agent=Mozilla --content-disposition -E -c "${BEPINEX_VR_TS_DOWNLOAD_URL}" ; then
        echo "---Successfully downloaded BepInEx for V Rising v${LAT_V}---"
    else
        echo "---Something went wrong, can't download BepInEx for V Rising v${LAT_V}, putting container into sleep mode!---"
        sleep infinity
    fi
    unzip -o ${SERVER_DIR}/BepInEx.zip -d /tmp/BepInEx 
    if [ $? -eq 0 ];then
        cp -rf /tmp/BepInEx/BepInEx*/* ${SERVER_DIR}/
        cp /tmp/BepInEx/README* ${SERVER_DIR}/README_BepInEx_for_VRising.txt
        touch ${SERVER_DIR}/BepInEx-${LAT_V}
        cp -R /tmp/Backup/config ${SERVER_DIR}/BepInEx/
        rm -rf ${SERVER_DIR}/BepInEx.zip /tmp/BepInEx /tmp/Backup
    else
        echo "---Unable to unzip BepInEx archive! Putting container into sleep mode!---"
        sleep infinity
    fi
elif [ "${CUR_V}" == "${LAT_V}" ]; then
    echo "---BepInEx v$CUR_V up-to-date---"
fi

export WINEARCH=win64
export WINEPREFIX="$server_dir"/WINE64

echo "--- Checking if WINE workdirectory is present ---"
if [ ! -d ${SERVER_DIR}/WINE64 ]; then
	echo "--- WINE workdirectory not found, creating please wait... ---"
    mkdir ${SERVER_DIR}/WINE64
else
	echo "--- WINE workdirectory found ---"
fi

echo "--- Checking if WINE is properly installed ---"
if [ ! -d ${SERVER_DIR}/WINE64/drive_c/windows ]; then
	echo "--- Setting up WINE ---"
    cd ${SERVER_DIR}
    winecfg > /dev/null 2>&1
    sleep 15
else
	echo "--- WINE properly set up ---"
fi

echo "--- Checking for old display lock files ---"

find /tmp -name ".X99*" -exec rm -f {} \; > /dev/null 2>&1

echo "--- Start Server ---"

xvfb-run --auto-servernum --server-args='-screen 0 640x480x24:32' wine64 ${SERVER_DIR}/VRisingServer.exe -persistentDataPath ${DATA_DIR} -serverName "${SERVER_NAME}" -saveName "${WORLD_NAME}" -logFile ${SERVER_DIR}/logs/VRisingServer.log ${GAME_PARAMS}
