FROM alpine:latest

MAINTAINER Andrew Cutler <andrew@panubo.com>

ENV RCLONE_VERSION=1.43 RCLONE_SHA1=07a5e7fa2302f321b2ea67a9f7d7d568367c5dd9

RUN apk add --update bash findutils gzip mariadb-client \
  && rm -rf /var/cache/apk/*

# Add rclone
RUN DIR=$(mktemp -d) \
  && cd ${DIR} \
  && wget -q https://github.com/ncw/rclone/releases/download/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-amd64.zip -O rclone.zip \
  && sha1sum rclone.zip \
  && echo "${RCLONE_SHA1}  rclone.zip" | sha1sum -c - \
  && unzip rclone.zip \
  && mv rclone-v${RCLONE_VERSION}-linux-amd64/rclone /usr/local/bin \
  && rm -rf ${DIR}

COPY commands /commands

ENTRYPOINT ["/commands/entry.sh"]

CMD ["default"]
