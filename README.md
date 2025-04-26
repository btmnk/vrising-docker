# Usage

```sh
git clone git@github.com:btmnk/vrising-docker.git

cd vrising-docker

# create .env file and configure if necessary
cp .env.example .env

# build the container and let the default settings generate
docker compsoe up
```

After the server started once it will have downloaded the latest vrising server files into `/server`, save data into `/data` and a copy of the server settings into `/settings`.

Only edit the settings files in `/settings`, they will be copied to the actual server data when starting the server. \
You will have to restart the server after changing settings.

##### Server List

Make sure to set `ListOnSteam` and `ListOnEOS` to `true` in the `ServerHostSettings.json`

##### Ports

By default V Rising will use the ports 9876/udp and 9877/udp but you can change them if you need to. \
Make sure to adjust the docker-compose.yml and the `ServerHostSettings.json`.

### Backups

Just run `./backup.sh`.
You can configure the max amount of backups in the `.env` file.