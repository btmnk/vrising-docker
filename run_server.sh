#!/bin/bash

export WINEDLLOVERRIDES="winhttp=n,b"
export WINEARCH=win64
export WINEPREFIX="$server_dir"/WINE64

# Server files
server_dir=/mnt/vrising/server

# Save files and settings
data_dir=/mnt/vrising/data

echo "--- Update server"
/usr/bin/steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir "$server_dir" +login anonymous +app_update 1829350 validate +quit
echo "--- Update done"

# Run Bepinex Updater
. ./update_bepinex.sh $server_dir

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

# echo "--- Updating winetricks ---"
# xvfb-run --auto-servernum --server-args='-screen 0 640x480x24:32' echo "Y" | winetricks --self-update

#echo "--- Installing dotnet6 ---"
# xvfb-run --auto-servernum --server-args='-screen 0 640x480x24:32' winetricks dotnet6 -q

echo "--- Checking for old display lock files ---"
find /tmp -name ".X99*" -exec rm -f {} \; > /dev/null 2>&1

echo "--- Start Server ---"
cd ${server_dir}

xvfb-run --auto-servernum --server-args='-screen 0 640x480x24:32' wine64 ${server_dir}/VRisingServer.exe -persistentDataPath ${data_dir} -serverName "${SERVER_NAME}" -saveName "${WORLD_NAME}" -logFile ${server_dir}/logs/VRisingServer.log ${GAME_PARAMS}
