FROM alpine:latest

MAINTAINER Andrew Cutler <andrew@panubo.com>

ENV RCLONE_VERSION=1.42 RCLONE_SHA256=7a623f60a5995f33cca3ed285210d8701c830f6f34d4dc50d74d75edd6a5bfa6

RUN apk add --update bash findutils gzip mariadb-client \
  && rm -rf /var/cache/apk/*

# Add rclone
RUN DIR=$(mktemp -d) \
  && cd ${DIR} \
  && wget -q https://github.com/ncw/rclone/releases/download/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-amd64.zip -O rclone.zip \
  && sha256sum rclone.zip \
  && echo "${RCLONE_SHA256}  rclone.zip" | sha256sum -c - \
  && unzip rclone.zip \
  && mv rclone-v${RCLONE_VERSION}-linux-amd64/rclone /usr/local/bin \
  && rm -rf ${DIR}

COPY commands /commands

ENTRYPOINT ["/commands/entry.sh"]

CMD ["default"]
