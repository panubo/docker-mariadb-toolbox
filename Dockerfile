FROM alpine:3.17

RUN set -x \
  && apk add --update bash findutils mariadb-client gzip bzip2 lz4 xz unzip zip coreutils python3 rsync curl \
  && rm -rf /var/cache/apk/* \
  ;

# Install Gcloud SDK (required for gsutil workload identity authentication)
ENV \
  GCLOUD_VERSION=424.0.0 \
  GCLOUD_CHECKSUM=1fed39626f23352e0f97623d5009ff1bb6c4ffd3875c85f4205f309292696b18

RUN set -x \
  && apk --no-cache add python3 \
  && curl -o /tmp/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz -L https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz \
  && echo "${GCLOUD_CHECKSUM}  google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM || ( echo "Expected $(sha256sum google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz)"; exit 1; )) \
  && tar -C / -zxvf /tmp/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz \
  && /google-cloud-sdk/install.sh --quiet \
  && ln -s /google-cloud-sdk/bin/gcloud /usr/local/bin/ \
  && ln -s /google-cloud-sdk/bin/gsutil /usr/local/bin/ \
  && rm -rf /tmp/* /root/.config/gcloud \
  ;

# Install AWS CLI
ENV \
  PYTHONIOENCODING=UTF-8 \
  PYTHONUNBUFFERED=0 \
  PAGER=more \
  AWS_CLI_VERSION=1.27.103 \
  AWS_CLI_CHECKSUM=0fed454146160807e273c4fd9bb1d0ba0926e3fb8ed3fc55e9251ebd2d53407c

RUN set -x \
  && apk --update add --no-cache ca-certificates wget unzip \
  && cd /tmp \
  && wget -nv https://s3.amazonaws.com/aws-cli/awscli-bundle-${AWS_CLI_VERSION}.zip -O /tmp/awscli-bundle-${AWS_CLI_VERSION}.zip \
  && echo "${AWS_CLI_CHECKSUM}  awscli-bundle-${AWS_CLI_VERSION}.zip" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM || ( echo "Expected $(sha256sum awscli-bundle-${AWS_CLI_VERSION}.zip)"; exit 1; )) \
  && unzip awscli-bundle-${AWS_CLI_VERSION}.zip \
  && /tmp/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
  && apk del wget unzip \
  && rm -rf /var/cache/apk/* \
  && rm -rf /tmp/* \
  ;

COPY commands /commands

ENTRYPOINT ["/commands/entry.sh"]

CMD ["default"]
