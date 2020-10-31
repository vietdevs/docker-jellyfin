FROM hotio/base@sha256:7760e163744ec91c96913f81c21b909eb5248e9ff7bfc36495f55e674f5efe34

ARG DEBIAN_FRONTEND="noninteractive"

EXPOSE 8096

# install packages
RUN apt update && \
    apt install -y --no-install-recommends --no-install-suggests \
        libicu60 \
        libass9 libbluray2 libdrm2 libfribidi0 libmp3lame0 libopus0 libtheora0 libva-drm2 libva2 libvdpau1 libvorbis0a libvorbisenc2 libwebp6 libwebpmux3 libx11-6 libx264-152 libx265-146 libzvbi0 \
        at \
        libfontconfig1 \
        libfreetype6 \
        libomxil-bellagio0 \
        libomxil-bellagio-bin && \
# clean up
    apt autoremove -y && \
    apt clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

ARG FFMPEG_VERSION
RUN debfile="/tmp/ffmpeg.deb" && curl -fsSL -o "${debfile}" "https://repo.jellyfin.org/releases/server/ubuntu/ffmpeg/jellyfin-ffmpeg_${FFMPEG_VERSION}-bionic_arm64.deb" && dpkg --install "${debfile}" && rm "${debfile}"

ARG VERSION
ARG SERVER_URL_ARM64
ARG WEB_VERSION
RUN zipfile="/tmp/jellyfin-server.zip" && curl -fsSL -o "${zipfile}" "${SERVER_URL_ARM64}" && unzip -q "${zipfile}" -d "/tmp" && rm "${zipfile}" && \
    debfile="/tmp/jellyfin-server-ubuntu.arm64/jellyfin-server_${VERSION}-unstable_arm64.deb" && dpkg --install "${debfile}" && rm -rf "/tmp/jellyfin-server-ubuntu.arm64" && \
    debfile="/tmp/jellyfin-web.deb" && curl -fsSL -o "${debfile}" "https://repo.jellyfin.org/releases/server/ubuntu/unstable/web/jellyfin-web_${WEB_VERSION}-unstable_all.deb" && dpkg --install "${debfile}" && rm "${debfile}"

COPY root/ /
