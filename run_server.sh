#!/bin/bash

#
# Credits to https://github.com/TrueOsiris/docker-vrising/tree/main since many of the snippets here are based on their repo
#

# Server files
server_dir=/mnt/vrising/server

# Save files
data_dir=/mnt/vrising/data

# Settings
settings_dir=/mnt/vrising/settings

export WINEARCH=win64
export WINEPREFIX="$server_dir"/.wine64

mkdir -p /root/.steam 2>/dev/null
chmod -R 777 /root/.steam 2>/dev/null

echo "--- Update server"
/usr/bin/steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir "$server_dir" +login anonymous +app_update 1829350 validate +quit
echo "--- Update done"

echo "--- Checking if WINE workdirectory is present ---"
if [ ! -d ${WINEPREFIX} ]; then
	echo "--- WINE workdirectory not found, creating please wait... ---"
    mkdir ${WINEPREFIX}
else
	echo "--- WINE workdirectory found ---"
fi

mkdir "$settings_dir" 2>/dev/null
if [ ! -f "$settings_dir/ServerGameSettings.json" ]; then
        echo "$settings_dir/ServerGameSettings.json not found. Copying default file."
        cp "$server_dir/VRisingServer_Data/StreamingAssets/Settings/ServerGameSettings.json" "$settings_dir" 2>&1
fi
if [ ! -f "$settings_dir/ServerHostSettings.json" ]; then
        echo "$settings_dir/ServerHostSettings.json not found. Copying default file."
        cp "$server_dir/VRisingServer_Data/StreamingAssets/Settings/ServerHostSettings.json" "$settings_dir" 2>&1
fi

echo "--- Copy settings to server ---"
cp "$settings_dir/ServerHostSettings.json" "$server_dir/VRisingServer_Data/StreamingAssets/Settings/ServerHostSettings.json"
cp "$settings_dir/ServerGameSettings.json" "$server_dir/VRisingServer_Data/StreamingAssets/Settings/ServerGameSettings.json"

echo "--- Checking for old display lock files ---"
rm /tmp/.X0-lock 2>&1

echo "--- Starting Xvfb ---"
Xvfb :0 -screen 0 1024x768x16 &

echo "--- Launching wine64 V Rising ---"
start_server() {
        export SteamAppId=1604030
	DISPLAY=:0.0 wine64 $server_dir/VRisingServer.exe -persistentDataPath $data_dir -serverName "$SERVER_NAME" -logFile "$server_dir/VRisingServer.log" 2>&1 &
}

start_server

# Gets the PID of the last command
ServerPID=$!

# Create logfile if server was not fast enough to create it
if [ ! -f "$settings_dir/ServerGameSettings.json" ]; then
	touch "$server_dir/VRisingServer.log"
fi

# Tail log file and waits for Server PID to exit
/usr/bin/tail -n 0 -F "$server_dir/VRisingServer.log" &
wait $ServerPID
