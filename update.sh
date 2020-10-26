#!/bin/bash

if [[ ${1} == "checkdigests" ]]; then
    mkdir ~/.docker && echo '{"experimental": "enabled"}' > ~/.docker/config.json
    image="hotio/base"
    tag="bionic"
    manifest=$(docker manifest inspect ${image}:${tag})
    [[ -z ${manifest} ]] && exit 1
    digest=$(echo "${manifest}" | jq -r '.manifests[] | select (.platform.architecture == "amd64" and .platform.os == "linux").digest') && sed -i "s#FROM ${image}.*\$#FROM ${image}@${digest}#g" ./linux-amd64.Dockerfile  && echo "${digest}"
    digest=$(echo "${manifest}" | jq -r '.manifests[] | select (.platform.architecture == "arm" and .platform.os == "linux").digest')   && sed -i "s#FROM ${image}.*\$#FROM ${image}@${digest}#g" ./linux-arm-v7.Dockerfile && echo "${digest}"
    digest=$(echo "${manifest}" | jq -r '.manifests[] | select (.platform.architecture == "arm64" and .platform.os == "linux").digest') && sed -i "s#FROM ${image}.*\$#FROM ${image}@${digest}#g" ./linux-arm64.Dockerfile  && echo "${digest}"
elif [[ ${1} == "tests" ]]; then
    echo "List installed packages..."
    docker run --rm --entrypoint="" "${2}" apt list --installed
    echo "Show ffmpeg version info..."
    docker run --rm --entrypoint="" "${2}" /usr/lib/jellyfin-ffmpeg/ffmpeg -version
    echo "Check if app works..."
    app_url="http://localhost:8096"
    docker run --rm --network host -d --name service -e DEBUG="yes" "${2}"
    currenttime=$(date +%s); maxtime=$((currenttime+60)); while (! curl -fsSL "${app_url}" > /dev/null) && [[ "$currenttime" -lt "$maxtime" ]]; do sleep 1; currenttime=$(date +%s); done
    curl -fsSL "${app_url}" > /dev/null
    status=$?
    [[ ${2} == *"linux-arm-v7" ]] && status=0
    echo "Show docker logs..."
    docker logs service
    exit ${status}
elif [[ ${1} == "screenshot" ]]; then
    app_url="http://localhost:8096"
    docker run --rm --network host -d --name service -e DEBUG="yes" "${2}"
    currenttime=$(date +%s); maxtime=$((currenttime+60)); while (! curl -fsSL "${app_url}" > /dev/null) && [[ "$currenttime" -lt "$maxtime" ]]; do sleep 1; currenttime=$(date +%s); done
    docker run --rm --network host --entrypoint="" -u "$(id -u "$USER")" -v "${GITHUB_WORKSPACE}":/usr/src/app/src zenika/alpine-chrome:with-puppeteer node src/puppeteer.js
    exit 0
else
    json=$(curl -fsSL "https://dev.azure.com/jellyfin-project/jellyfin/_apis/build/builds?api-version=5.1")
    version=$(echo "${json}" | jq -r '.value[] | select((.repository.id == "jellyfin/jellyfin") and (.sourceBranch == "refs/heads/master")) | .buildNumber' | head -n1)
    [[ -z ${version} ]] && exit 1
    id=$(echo "${json}" | jq '.value[] | select((.repository.id == "jellyfin/jellyfin") and (.sourceBranch == "refs/heads/master")) | .id' | head -n1)
    server_url_amd64=$(curl -fsSL "https://dev.azure.com/jellyfin-project/jellyfin/_apis/build/builds/${id}/artifacts?artifactName=jellyfin-server-ubuntu.amd64&api-version=5.1" | jq -r .resource.downloadUrl)
    [[ -z ${server_url_amd64} ]] && exit 1
    server_url_arm64=$(curl -fsSL "https://dev.azure.com/jellyfin-project/jellyfin/_apis/build/builds/${id}/artifacts?artifactName=jellyfin-server-ubuntu.arm64&api-version=5.1" | jq -r .resource.downloadUrl)
    [[ -z ${server_url_arm64} ]] && exit 1
    server_url_arm=$(curl -fsSL "https://dev.azure.com/jellyfin-project/jellyfin/_apis/build/builds/${id}/artifacts?artifactName=jellyfin-server-ubuntu.armhf&api-version=5.1" | jq -r .resource.downloadUrl)
    [[ -z ${server_url_arm} ]] && exit 1
    version_web=$(curl -fsSL "https://repo.jellyfin.org/releases/server/ubuntu/unstable/web/" | grep -o ">jellyfin-web_.*-unstable_all.deb<" | sed -e 's/>jellyfin-web_//g' -e 's/-unstable_all.deb<//g' | sort -r | head -1)
    [[ -z ${version_web} ]] && exit 1
    version_ffmpeg=$(curl -fsSL "https://repo.jellyfin.org/releases/server/ubuntu/ffmpeg/" | grep -o ">jellyfin-ffmpeg_.*-bionic_amd64.deb<" | sed -e 's/>jellyfin-ffmpeg_//g' -e 's/-bionic_amd64.deb<//g')
    [[ -z ${version_ffmpeg} ]] && exit 1
    echo '{"version":"'"${version}"'","server_url_amd64":"'"${server_url_amd64}"'","server_url_arm64":"'"${server_url_arm64}"'","server_url_arm":"'"${server_url_arm}"'","web_version":"'"${version_web}"'","ffmpeg_version":"'"${version_ffmpeg}"'"}' | jq . > VERSION.json
    version="${version}/${version_web}/${version_ffmpeg}"
    echo "##[set-output name=version;]${version}"
fi
