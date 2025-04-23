#!/bin/bash

# Server files
server_dir=/mnt/vrising/server

# Save files and settings
data_dir=/mnt/vrising/data

# Settings
settings_dir=/mnt/vrising/settings

export WINEDLLOVERRIDES="winhttp=n,b"
export WINEARCH=win64
export WINEPREFIX="$server_dir"/.wine64

mkdir -p /root/.steam 2>/dev/null
chmod -R 777 /root/.steam 2>/dev/null

echo "--- Update server"
/usr/bin/steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir "$server_dir" +login anonymous +app_update 1829350 validate +quit
echo "--- Update done"

echo "--- Checking if WINE workdirectory is present ---"
if [ ! -d ${server_dir}/WINE64 ]; then
	echo "--- WINE workdirectory not found, creating please wait... ---"
    mkdir ${server_dir}/WINE64
else
	echo "--- WINE workdirectory found ---"
fi

if ! grep -o 'avx[^ ]*' /proc/cpuinfo; then
	unsupported_file="VRisingServer_Data/Plugins/x86_64/lib_burst_generated.dll"
	echo "AVX or AVX2 not supported; Check if unsupported ${unsupported_file} exists"
	if [ -f "${s}/${unsupported_file}" ]; then
		echo "Changing ${unsupported_file} as attempt to fix issues..."
		mv "${s}/${unsupported_file}" "${s}/${unsupported_file}.bak"
	fi
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
	DISPLAY=:0.0 wine64 $server_dir/VRisingServer.exe -persistentDataPath $data_dir -serverName "$SERVER_NAME" -logFile "$server_dir/VRisingServer.log" 2>&1 &
}

start_server

# Gets the PID of the last command
ServerPID=$!

# Tail log file and waits for Server PID to exit
/usr/bin/tail -n 0 -f "$p/$logfile" &
wait $ServerPID
