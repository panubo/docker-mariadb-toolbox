FROM alpine:3.22

RUN set -x \
  && apk add --update bash findutils mariadb-client gzip bzip2 lz4 xz unzip zip coreutils python3 rsync curl aws-cli \
  && rm -rf /var/cache/apk/* \
  ;

# Install Gcloud SDK (required for gsutil workload identity authentication)
ENV \
  GCLOUD_VERSION=542.0.0 \
  GCLOUD_CHECKSUM_X86_64=6ac032650f507e61cf0b68a462be7e97edc9352cb3b95ce9a0d32cd8a4cfdfd5 \
  GCLOUD_CHECKSUM_AARCH64=6b732c2e38da8d03395688fd4460b6d28a63a6d6d140836f4ecc1eee198be5e7

# Install Gcloud SDK
RUN set -x \
&& if [ "$(uname -m)" = "x86_64" ] ; then \
        GCLOUD_CHECKSUM="${GCLOUD_CHECKSUM_X86_64}"; \
        ARCH="x86_64"; \
    elif [ "$(uname -m)" = "aarch64" ]; then \
        GCLOUD_CHECKSUM="${GCLOUD_CHECKSUM_AARCH64}"; \
        ARCH="arm"; \
    fi \
&& curl -o /tmp/google-cloud-sdk-${GCLOUD_VERSION}-linux-${ARCH}.tar.gz -L https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-${ARCH}.tar.gz \
&& echo "${GCLOUD_CHECKSUM}  google-cloud-sdk-${GCLOUD_VERSION}-linux-${ARCH}.tar.gz" > /tmp/SHA256SUM \
&& ( cd /tmp; sha256sum -c SHA256SUM || ( echo "Expected $(sha256sum google-cloud-sdk-${GCLOUD_VERSION}-linux-${ARCH}.tar.gz)"; exit 1; )) \
&& tar -C / -zxvf /tmp/google-cloud-sdk-${GCLOUD_VERSION}-linux-${ARCH}.tar.gz \
&& /google-cloud-sdk/install.sh --quiet \
&& ln -s /google-cloud-sdk/bin/gcloud /usr/local/bin/ \
&& ln -s /google-cloud-sdk/bin/gsutil /usr/local/bin/ \
&& rm -rf /tmp/* /root/.config/gcloud \
;

COPY commands /commands

ENTRYPOINT ["/commands/entry.sh"]

CMD ["default"]
