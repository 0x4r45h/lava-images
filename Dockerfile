FROM debian:stable-20230109-slim as builder

RUN apt-get update && apt-get install -y curl jq bash nano git

ARG REPO_URL=https://github.com/K433QLtr6RA9ExEq/GHFkqmTzpdNLDd6T.git
ARG REPO_PATH=GHFkqmTzpdNLDd6T/testnet-1
ARG BINARY_VERSION=v0.3.0

RUN git clone $REPO_URL
RUN mkdir -p "/tmp/repo" && mv $REPO_PATH/* /tmp/repo
RUN curl -L https://lava-binary-upgrades.s3.amazonaws.com/testnet/$BINARY_VERSION/lavad -o /tmp/lavad \
    && chmod +x /tmp/lavad

FROM debian:stable-20230109-slim
RUN apt-get update && apt-get install -y curl jq bash nano git

RUN mkdir -p "/root/.lava" && mkdir -p "/root/.lava/config"
COPY --from=builder /tmp/repo/default_lavad_config_files/* /root/.lava/config/
COPY --from=builder /tmp/repo/genesis_json/genesis.json /root/.lava/config/genesis.json
COPY --from=builder /tmp/lavad /usr/local/bin/lavad

ENTRYPOINT ["lavad"]
CMD ["--help"]