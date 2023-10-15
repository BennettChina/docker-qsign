FROM alpine AS BASE

ARG QSign_VERSION="1.1.9"
ARG QQ_VERSION="8.9.63"

RUN apk add --no-cache --update \
        		ca-certificates &&  \
    wget https://github.com/fuqiuluo/unidbg-fetch-qsign/releases/download/$QSign_VERSION/unidbg-fetch-qsign.3.zip && \
    wget https://raw.githubusercontent.com/fuqiuluo/unidbg-fetch-qsign/master/txlib/$QQ_VERSION/libfekit.so && \
    wget https://raw.githubusercontent.com/fuqiuluo/unidbg-fetch-qsign/master/txlib/$QQ_VERSION/config.json && \
    wget https://raw.githubusercontent.com/fuqiuluo/unidbg-fetch-qsign/master/txlib/$QQ_VERSION/dtconfig.json && \
    sed -i 's|"port": 8080|"port": 80|' config.json && \
    mkdir -p "/resource/qsign/txlib/" && \
    unzip -q ./unidbg-fetch-qsign.3.zip && \
    unzip -q ./unidbg-fetch-qsign-${QSign_VERSION}.zip && \
    mv ./unidbg-fetch-qsign-${QSign_VERSION}/* "/resource/qsign/" && \
    mv libfekit.so "/resource/qsign/txlib/" && \
    mv config.json "/resource/qsign/txlib/" && \
    mv dtconfig.json "/resource/qsign/txlib/" && \
    sed -i 's|4332|4416|' "/resource/qsign/txlib/8.9.73/config.json"


FROM eclipse-temurin:8-jre-alpine

ARG GOSU_VERSION=1.16
ARG QSign_VERSION="1.1.9"

LABEL authors="Bennett"
LABEL description="QQ签名API服务"
LABEL version="$QSign_VERSION"

ENV TZ=Asia/Shanghai

RUN apk add --no-cache --update \
    libstdc++ \
    gcompat && \
    cp /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    mkdir "/app" && \
    rm -rf /var/cache/apk/* && \
    addgroup -S -g 1000 qsign && adduser -S -G qsign -u 999 qsign && \
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
COPY txlib /app/txlib/

WORKDIR /app

VOLUME /app/txlib

ENTRYPOINT ["sh", "docker-entrypoint.sh"]

CMD ["bin/unidbg-fetch-qsign", "--basePath=/app/txlib"]