FROM alpine:3

LABEL org.opencontainers.image.authors="admin@minenet.at"
LABEL org.opencontainers.image.source="https://github.com/ich777/docker-terraria-server"

ARG TARGETPLATFORM

RUN apk add --no-cache screen unzip curl && \
	if [ "$TARGETPLATFORM" == "linux/arm64" ]; then \
	  apk add --no-cache mono --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
	fi

RUN wget -O /tmp/gotty.tar.gz https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz && \
	tar -C /usr/bin/ -xvf /tmp/gotty.tar.gz && \
	rm -rf /tmp/gotty.tar.gz

ENV DATA_DIR="/serverdata"
ENV SERVER_DIR="${DATA_DIR}/serverfiles"
ENV GAME_VERSION="template"
ENV GAME_MOD="template"
ENV GAME_PARAMS="-config serverconfig.txt"
ENV TERRARIA_SRV_V="1.4.4.9"
ENV ENABLE_AUTOUPDATE="true"
ENV ENABLE_WEBCONSOLE="true"
ENV GOTTY_PARAMS="-w --title-format Terraria"
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV DATA_PERM=770
ENV USER="terraria"

RUN mkdir $DATA_DIR && \
	mkdir $SERVER_DIR && \
	useradd -d $DATA_DIR -s /bin/bash $USER && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
ADD /config/ /config/
RUN chmod -R 777 /opt/scripts/

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]