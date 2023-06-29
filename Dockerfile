FROM alpine AS BASE

ARG QSign_VERSION="1.0.4"
ARG QQ_VERSION="8.9.63"

RUN apk add --no-cache --update \
        		ca-certificates &&  \
    wget https://github.com/fuqiuluo/unidbg-fetch-qsign/releases/download/$QSign_VERSION/unidbg-fetch-qsign-$QSign_VERSION.zip && \
    wget https://raw.githubusercontent.com/fuqiuluo/unidbg-fetch-qsign/master/txlib/$QQ_VERSION/libQSec.so && \
    wget https://raw.githubusercontent.com/fuqiuluo/unidbg-fetch-qsign/master/txlib/$QQ_VERSION/libfekit.so && \
    mkdir -p "/resource/qsign/txlib/" && \
    unzip -q ./unidbg-fetch-qsign-$QSign_VERSION.zip && \
    mv ./unidbg-fetch-qsign-$QSign_VERSION/* "/resource/qsign/" && \
    mv libQSec.so "/resource/qsign/txlib/" && \
    mv libfekit.so "/resource/qsign/txlib/"


FROM eclipse-temurin:8-jre-alpine

ARG GOSU_VERSION=1.16
ARG QSign_VERSION="1.0.4"

LABEL authors="bennett"
LABEL description="QQ签名API服务"
LABEL version="$QSign_VERSION"

ENV TZ=Asia/Shanghai \
    COUNT=1 \
    ANDROID_ID=""

RUN apk add --no-cache --update \
    libstdc++ \
    gcompat && \
    cp /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    mkdir "/app" && \
    rm -rf /var/cache/apk/* && \
    addgroup -S qsign && adduser -S qsign -G qsign && \
        set -eux; \
        	\
        	apk add --no-cache --update --virtual .gosu-deps \
        		ca-certificates \
        		dpkg \
        		gnupg \
        	; \
        	\
        	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
        	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
        	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
        	\
        # verify the signature
        	export GNUPGHOME="$(mktemp -d)"; \
        	gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
        	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
        	command -v gpgconf && gpgconf --kill all || :; \
        	rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
        	\
        # clean up fetch dependencies
        	apk del --no-network .gosu-deps; \
        	\
        	chmod +x /usr/local/bin/gosu; \
        # verify that the binary works
        	gosu --version; \
        	gosu nobody true

COPY --from=BASE "/resource/qsign/" "/app/"
COPY docker-entrypoint.sh /app/

WORKDIR /app

VOLUME /app/txlib

EXPOSE 80

ENTRYPOINT ["sh", "docker-entrypoint.sh"]