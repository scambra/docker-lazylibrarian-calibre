FROM lsiobase/ubuntu:focal

# set version label
ARG BUILD_DATE
ARG VERSION
ARG DEBIAN_FRONTEND=noninteractive
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="scambra"

RUN \
 echo "**** install build packages ****" && \
 apt-get update && \
 apt-get install -y \
	libjpeg-turbo8-dev \
	python3-pip \
	zlib1g-dev \
	patch && \
 echo "**** install runtime packages ****" && \
 apt-get install -y \
	ghostscript \
	libjpeg-turbo8 \
	python3-minimal \
	python3-openssl \
	unrar \
	calibre-bin \
	zlib1g && \
 pip3 install --no-cache-dir -U \
	apprise \
	Pillow
COPY cmd_list_categories.patch /tmp/cmd_list_categories.patch
RUN patch /usr/lib/calibre/calibre/db/cli/cmd_list_categories.py < /tmp/cmd_list_categories.patch
RUN \
 echo "**** cleanup ****" && \
 apt-get -y purge \
	libjpeg-turbo8-dev \
	python3-pip \
	zlib1g-dev \
	patch && \
 apt-get -y autoremove && \
 rm -rf \
	/var/lib/apt/lists/* \
	/var/tmp/*

ARG LAZYLIBRARIAN_COMMIT
COPY lazylibrarian_commit /defaults/version.txt
RUN \
 echo "**** install app ****" && \
 mkdir -p \
	/app/lazylibrarian && \
 if [ -z ${LAZYLIBRARIAN_COMMIT+x} ]; then \
 	LAZYLIBRARIAN_COMMIT=$(cat /defaults/version.txt); \
 else \
  echo "${LAZYLIBRARIAN_COMMIT}" > /defaults/version.txt \
 fi && \
 echo "Installing from commit ${LAZYLIBRARIAN_COMMIT}" && \
 curl -o \
 /tmp/lazylibrarian.tar.gz -L \
	"https://gitlab.com/LazyLibrarian/LazyLibrarian/repository/archive.tar.gz?sha={$LAZYLIBRARIAN_COMMIT}" && \
 tar xf \
  /tmp/lazylibrarian.tar.gz -C \
	/app/lazylibrarian --strip-components=1 && \
 rm -rf /tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 5299
VOLUME /books /config
