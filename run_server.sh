#!/bin/bash

#
# Credits to https://github.com/TrueOsiris/docker-vrising/tree/main since many of the snippets here are based on their repo
#

# Server files
server_dir=/mnt/vrising/server
log_file="latest.log"

# Save files
data_dir=/mnt/vrising/data

# Settings
settings_dir=/mnt/vrising/settings

export WINEARCH=win64
export WINEPREFIX="$server_dir"/.wine64

mkdir -p /root/.steam 2>/dev/null
chmod -R 777 /root/.steam 2>/dev/null

echo "--- Updating server..."
/usr/bin/steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir "$server_dir" +login anonymous +app_update 1829350 validate +quit
echo "--- ✅ Update done"

echo "--- Checking if WINE workdirectory is present ---"
if [ ! -d ${WINEPREFIX} ]; then
	echo "--- WINE workdirectory not found, creating please wait... ---"
        mkdir ${WINEPREFIX}
	echo "--- ✅ WINE workdirectory created ---"
else
	echo "--- ✅ WINE workdirectory found ---"
fi

# Create logfile so it can be tailed before the server generates it
if [ ! -f "$server_dir/$log_file" ]; then
        mkdir -p "$server_dir"
	touch "$server_dir/$log_file"
fi

mkdir "$settings_dir" 2>/dev/null
if [ ! -f "$settings_dir/ServerGameSettings.json" ]; then
        echo "$settings_dir/ServerGameSettings.json not found. Copying default file."
        cp "$server_dir/VRisingServer_Data/StreamingAssets/Settings/ServerGameSettings.json" "$settings_dir" 2>&1
	echo "--- ✅ Copied default ServerGameSettings to $settings_dir ---"
fi
if [ ! -f "$settings_dir/ServerHostSettings.json" ]; then
        echo "$settings_dir/ServerHostSettings.json not found. Copying default file."
        cp "$server_dir/VRisingServer_Data/StreamingAssets/Settings/ServerHostSettings.json" "$settings_dir" 2>&1
	echo "--- ✅ Copied default ServerHostSettings to $settings_dir ---"
fi

echo "--- Copy settings to server ---"
cp "$settings_dir/ServerHostSettings.json" "$server_dir/VRisingServer_Data/StreamingAssets/Settings/ServerHostSettings.json"
cp "$settings_dir/ServerGameSettings.json" "$server_dir/VRisingServer_Data/StreamingAssets/Settings/ServerGameSettings.json"
echo "--- ✅ Applied settings ---"

echo "--- Checking for old display lock files ---"
rm /tmp/.X0-lock 2>&1

echo "--- Starting Xvfb ---"
Xvfb :0 -screen 0 1024x768x16 &

echo "--- Launching wine64 V Rising ---"
start_server() {
        export SteamAppId=1604030
	DISPLAY=:0.0 wine64 $server_dir/VRisingServer.exe -persistentDataPath $data_dir -logFile "$server_dir/$log_file" 2>&1 &
}

start_server

# Gets the PID of the last command
ServerPID=$!

# Tail log file and waits for Server PID to exit
/usr/bin/tail -n 0 -F "$server_dir/$log_file" &
wait $ServerPID
