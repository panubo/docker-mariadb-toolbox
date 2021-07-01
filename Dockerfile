FROM alpine:3.14

RUN set -x \
  && apk add --update bash findutils mariadb-client gzip bzip2 lz4 xz unzip zip coreutils python3 rsync curl \
  && ln -s /usr/bin/python3 /usr/bin/python \
  &&  rm -rf /var/cache/apk/* \
  ;

# Install Gcloud SDK (required for gsutil workload identity authentication)
ENV \
  GCLOUD_VERSION=331.0.0 \
  GCLOUD_CHECKSUM=f90c2df5bd0b3498d7e33112f17439eead8c94ae7d60a1cab0091de0eee62c16

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
