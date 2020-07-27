FROM alpine:3.12

RUN set -x \
  && apk add --update bash findutils mariadb-client gzip bzip2 lz4 xz unzip zip coreutils python3 rsync curl \
  && ln -s /usr/bin/python3 /usr/bin/python \
  &&  rm -rf /var/cache/apk/* \
  ;

ENV \
  GSUTIL_VERSION=4.52 \
  GSUTIL_CHECKSUM=411c83d586b57490b0040e132fc6e5d00e59b1be536ec92267f0b37a5968cd1a \
  CLOUDSDK_GSUTIL_PYTHON=python3 \
  CLOUDSDK_PYTHON=python3

# Install gsutil
RUN set -x \
  && mkdir -p /opt \
  && curl -o /tmp/gsutil_${GSUTIL_VERSION}.tar.gz "https://storage.googleapis.com/pub/gsutil_${GSUTIL_VERSION}.tar.gz" \
  && echo "${GSUTIL_CHECKSUM}  gsutil_${GSUTIL_VERSION}.tar.gz" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM; ) \
  && tar -C /opt -zxf /tmp/gsutil_${GSUTIL_VERSION}.tar.gz \
  && ln -s /opt/gsutil/gsutil /usr/local/bin/gsutil \
  && rm -f /tmp/* \
  && find /opt ! -group 0 -exec chgrp -h 0 {} \; \
  ;

# Install AWS CLI
ENV \
  PYTHONIOENCODING=UTF-8 \
  PYTHONUNBUFFERED=0 \
  PAGER=more \
  AWS_CLI_VERSION=1.18.93 \
  AWS_CLI_CHECKSUM=37eaa4d25cb1b9786af4ab6858cce7dfca154d264554934690d99994a7bbd7a5

RUN set -x \
  && apk add --no-cache ca-certificates wget \
  && cd /tmp \
  && wget -nv https://s3.amazonaws.com/aws-cli/awscli-bundle-${AWS_CLI_VERSION}.zip -O /tmp/awscli-bundle-${AWS_CLI_VERSION}.zip \
  && echo "${AWS_CLI_CHECKSUM}  awscli-bundle-${AWS_CLI_VERSION}.zip" > /tmp/SHA256SUM \
  && sha256sum -c SHA256SUM \
  && unzip awscli-bundle-${AWS_CLI_VERSION}.zip \
  && /tmp/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
  && apk del wget \
  && rm -rf /tmp/* \
  ;

COPY commands /commands

ENTRYPOINT ["/commands/entry.sh"]

CMD ["default"]
