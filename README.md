# jellyfin

<img src="https://raw.githubusercontent.com/hotio/unraid-templates/master/hotio/img/jellyfin.png" alt="Logo" height="130" width="130">

[![GitHub](https://img.shields.io/badge/source-github-lightgrey)](https://github.com/hotio/docker-jellyfin)
[![Docker Pulls](https://img.shields.io/docker/pulls/hotio/jellyfin)](https://hub.docker.com/r/hotio/jellyfin)
[![Discord](https://img.shields.io/discord/610068305893523457?color=738ad6&label=discord&logo=discord&logoColor=white)](https://discord.gg/3SnkuKp)
[![Upstream](https://img.shields.io/badge/upstream-project-yellow)](https://github.com/jellyfin/jellyfin)

## Starting the container

Just the basics to get the container running:

```shell
docker run --rm --name jellyfin -p 8096:8096 -v /<host_folder_config>:/config hotio/jellyfin
```

The environment variables below are all optional, the values you see are the defaults.

```shell
-e PUID=1000
-e PGID=1000
-e UMASK=002
-e TZ="Etc/UTC"
-e ARGS=""
-e DEBUG="no"
```

## Tags

| Tag                  | Description                      | Build Status                                                                                                                                                | Last Updated                                                                                                                                                          |
| ---------------------|----------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| latest               | The same as `stable`             |                                                                                                                                                             |                                                                                                                                                                       |
| stable               | Stable version                   | [![Build Status](https://cloud.drone.io/api/badges/hotio/docker-jellyfin/status.svg?ref=refs/heads/stable)](https://cloud.drone.io/hotio/docker-jellyfin)   | [![GitHub last commit (branch)](https://img.shields.io/github/last-commit/hotio/docker-jellyfin/stable)](https://github.com/hotio/docker-jellyfin/commits/stable)     |
| unstable             | Unstable version, nightly builds | [![Build Status](https://cloud.drone.io/api/badges/hotio/docker-jellyfin/status.svg?ref=refs/heads/unstable)](https://cloud.drone.io/hotio/docker-jellyfin) | [![GitHub last commit (branch)](https://img.shields.io/github/last-commit/hotio/docker-jellyfin/unstable)](https://github.com/hotio/docker-jellyfin/commits/unstable) |

You can also find tags that reference a commit or version number.

## Configuration location

Your jellyfin configuration inside the container is stored in `/config/app`, to migrate from another container, you'd probably have to move your files from `/config` to `/config/app`. The following jellyfin path locations are used.

```shell
JELLYFIN_CONFIG_DIR="/config/app"
JELLYFIN_DATA_DIR="/config/app/data"
JELLYFIN_LOG_DIR="/config/app/log"
JELLYFIN_CACHE_DIR="/config/app/cache"
```

## Hardware support

To make your hardware devices available inside the container use the following argument `--device=/dev/dri:/dev/dri` for Intel QuickSync and `--device=/dev/dvb:/dev/dvb` for a tuner. NVIDIA users should go visit the [NVIDIA github](https://github.com/NVIDIA/nvidia-docker) page for instructions. For Raspberry Pi OpenMAX you'll need to use `--device=/dev/vchiq:/dev/vchiq -v /opt/vc/lib:/opt/vc/lib`, V4L2 will need `--device=/dev/video10:/dev/video10 --device=/dev/video11:/dev/video11 --device=/dev/video12:/dev/video12` and MMAL needs `--device=/dev/vcsm:/dev/vcsm` or `--device=/dev/vc-mem:/dev/vc-mem`. For some methods it could happen that additional driver packages need to be installed. For example `i965-va-driver`, `mesa-va-drivers` or `libomxil-bellagio0 libomxil-bellagio-bin`. Use your own script to install these (see next section).

## Executing your own scripts

If you have a need to do additional stuff when the container starts or stops, you can mount your script with `-v /docker/host/my-script.sh:/etc/cont-init.d/99-my-script` to execute your script on container start or `-v /docker/host/my-script.sh:/etc/cont-finish.d/99-my-script` to execute it when the container stops. An example script can be seen below.

```shell
#!/usr/bin/with-contenv bash

echo "Hello, this is me, your script."
```

## Troubleshooting a problem

By default all output is redirected to `/dev/null`, so you won't see anything from the application when using `docker logs`. Most applications write everything to a log file too. If you do want to see this output with `docker logs`, you can use `-e DEBUG="yes"` to enable this.