FROM debian:bookworm-slim

LABEL org.opencontainers.image.authors="admin@minenet.at"
LABEL org.opencontainers.image.source="https://github.com/ich777/docker-terraria-server"

RUN echo "deb http://deb.debian.org/debian bookworm contrib non-free non-free-firmware" >> /etc/apt/sources.list && \
	apt-get update && apt-get -y upgrade && \
	apt-get -y install --no-install-recommends locales procps && \
	touch /etc/locale.gen && \
	echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
	locale-gen && \
	apt-get -y install --reinstall ca-certificates && \
	rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

ARG TARGETARCH

RUN apt-get update && \
	apt-get -y install --no-install-recommends screen unzip curl wget && \
	if [ "$TARGETARCH" = "arm64" ]; then \
		apt-get -y install --no-install-recommends dirmngr gnupg; \
		gpg --homedir /tmp --no-default-keyring --keyring /usr/share/keyrings/mono-official-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF; \
		echo "deb [signed-by=/usr/share/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/debian stable-buster main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list; \
		apt-get update; \
		apt-get -y install --no-install-recommends mono-xsp4; \
		apt-get remove -y --purge gnupg dirmngr; \
		apt-get autoremove -y; \
	fi && \
	rm -rf /var/lib/apt/lists/*

RUN curl -sL -o /tmp/gotty.tar.gz https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz && \
	tar -C /usr/bin/ -xvf /tmp/gotty.tar.gz && \
	rm -rf /tmp/gotty.tar.gz

ENV SERVER_DIR="/server"
ENV GAME_VERSION="template"
ENV GAME_MOD="template"
ENV GAME_PARAMS="-config serverconfig.txt"
ENV TERRARIA_SRV_V="1.4.4.9"
ENV ENABLE_AUTOUPDATE="true"
ENV ENABLE_WEBCONSOLE="true"
ENV GOTTY_PARAMS="-w --title-format Terraria"
ENV USER="terraria"

RUN mkdir $SERVER_DIR && \
	useradd -U -r $USER && \
	chown -R $USER:$USER $SERVER_DIR && \
	ulimit -n 2048

COPY --chmod 111 /scripts/ /opt/scripts/
COPY --chmod 666 /config/ /config/

VOLUME $SERVER_DIR

USER $USER

ENTRYPOINT ["/opt/scripts/start.sh"]
