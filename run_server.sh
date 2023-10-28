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
CUR_V="$(find ${server_dir} -maxdepth 1 -name "BepInEx-*" | cut -d '-' -f2)"
BEPINEX_VR_API_DATA="$(curl -s -X GET https://thunderstore.io/c/v-rising/api/v1/package/b86fcaaf-297a-45c8-82a0-fcbd7806fdc4/ -H "accept: application/json")"
LAT_V="$(echo ${BEPINEX_VR_API_DATA} | jq -r '.versions[0].version_number')"

if [ -z "${LAT_V}" ] && [ -z "${CUR_V}" ]; then
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
echo "--- ${BEPINEX_VR_TS_URL} ---"
echo

BEPINEX_VR_TS_DOWNLOAD_URL="$(echo ${BEPINEX_VR_API_DATA} | jq -r '.versions[0].download_url')"

if [ -z "${CUR_V}" ]; then
    echo "---BepInEx for V Rising not found, downloading and installing v${LAT_V}...---"
    cd ${server_dir}
    rm -rf ${server_dir}/BepInEx-*
    if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${server_dir}/BepInEx.zip --user-agent=Mozilla --content-disposition -E -c "${BEPINEX_VR_TS_DOWNLOAD_URL}" ; then
        echo "---Successfully downloaded BepInEx for V Rising v${LAT_V}---"
    else
        echo "---Something went wrong, can't download BepInEx for V Rising v${LAT_V}, putting container into sleep mode!---"
        sleep infinity
    fi
    mkdir -p /tmp/BepInEx
    unzip -o ${server_dir}/BepInEx.zip -d /tmp/BepInEx
    if [ $? -eq 0 ];then
        touch ${server_dir}/BepInEx-${LAT_V}
        cp -rf /tmp/BepInEx/BepInEx*/* ${server_dir}/
        cp /tmp/BepInEx/README* ${server_dir}/README_BepInEx_for_VRising.txt
        rm -rf ${server_dir}/BepInEx.zip /tmp/BepInEx
    else
        echo "---Unable to unzip BepInEx archive! Putting container into sleep mode!---"
        sleep infinity
    fi
elif [ "$CUR_V" != "${LAT_V}" ]; then
    echo "---Version missmatch, BepInEx v$CUR_V installed, downloading and installing v${LAT_V}...---"
    cd ${server_dir}
    rm -rf ${server_dir}/BepInEx-$CUR_V
    mkdir /tmp/Backup
    cp -R ${server_dir}/BepInEx/config /tmp/Backup/
    if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${server_dir}/BepInEx.zip --user-agent=Mozilla --content-disposition -E -c "${BEPINEX_VR_TS_DOWNLOAD_URL}" ; then
        echo "---Successfully downloaded BepInEx for V Rising v${LAT_V}---"
    else
        echo "---Something went wrong, can't download BepInEx for V Rising v${LAT_V}, putting container into sleep mode!---"
        sleep infinity
    fi
    unzip -o ${server_dir}/BepInEx.zip -d /tmp/BepInEx 
    if [ $? -eq 0 ];then
        cp -rf /tmp/BepInEx/BepInEx*/* ${server_dir}/
        cp /tmp/BepInEx/README* ${server_dir}/README_BepInEx_for_VRising.txt
        touch ${server_dir}/BepInEx-${LAT_V}
        cp -R /tmp/Backup/config ${server_dir}/BepInEx/
        rm -rf ${server_dir}/BepInEx.zip /tmp/BepInEx /tmp/Backup
    else
        echo "---Unable to unzip BepInEx archive! Putting container into sleep mode!---"
        sleep infinity
    fi
elif [ "${CUR_V}" == "${LAT_V}" ]; then
    echo "---BepInEx v$CUR_V up-to-date---"
fi

# BEPINEX END

export WINEARCH=win64
export WINEPREFIX="$server_dir"/WINE64

echo "--- Checking if WINE workdirectory is present ---"
if [ ! -d ${server_dir}/WINE64 ]; then
	echo "--- WINE workdirectory not found, creating please wait... ---"
    mkdir ${server_dir}/WINE64
else
	echo "--- WINE workdirectory found ---"
fi

echo "--- Checking if WINE is properly installed ---"
if [ ! -d ${server_dir}/WINE64/drive_c/windows ]; then
	echo "--- Setting up WINE ---"
    cd ${server_dir}
    winecfg > /dev/null 2>&1
    sleep 15
else
	echo "--- WINE properly set up ---"
fi

echo "--- Updating winetricks ---"
xvfb-run --auto-servernum --server-args='-screen 0 640x480x24:32' winetricks --self-update -q

echo "--- Installing dotnet6 ---"
xvfb-run --auto-servernum --server-args='-screen 0 640x480x24:32' winetricks dotnet6 -q

echo "--- Checking for old display lock files ---"
find /tmp -name ".X99*" -exec rm -f {} \; > /dev/null 2>&1

echo "--- Start Server ---"
cd ${server_dir}

xvfb-run --auto-servernum --server-args='-screen 0 640x480x24:32' wine64 ${server_dir}/VRisingServer.exe -persistentDataPath ${data_dir} -serverName "${SERVER_NAME}" -saveName "${WORLD_NAME}" -logFile ${server_dir}/logs/VRisingServer.log ${GAME_PARAMS}
