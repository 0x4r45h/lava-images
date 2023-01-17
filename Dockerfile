FROM golang:bullseye as builder

RUN apt-get update && apt-get install -y curl jq bash nano git unzip

ARG REPO_URL=https://github.com/K433QLtr6RA9ExEq/GHFkqmTzpdNLDd6T.git
ARG REPO_PATH=GHFkqmTzpdNLDd6T/testnet-1

WORKDIR "/tmp"
RUN git clone $REPO_URL
RUN mkdir -p "/tmp/repo" && mv $REPO_PATH/* /tmp/repo

RUN go install github.com/cosmos/cosmos-sdk/cosmovisor/cmd/cosmovisor@v1.0.0

RUN curl -L https://lava-binary-upgrades.s3.amazonaws.com/testnet/cosmovisor-upgrades/cosmovisor-upgrades.zip -o /tmp/cosmovisor-upgrades.zip

RUN unzip cosmovisor-upgrades.zip

FROM debian:stable-20230109-slim
RUN apt-get update && apt-get install -y curl jq bash nano git

RUN mkdir -p "/root/.lava" && mkdir -p "/root/.lava/config" && mkdir -p "/root/.lava/cosmovisor"
COPY --from=builder /tmp/repo/default_lavad_config_files/* /root/.lava/config/
COPY --from=builder /tmp/repo/genesis_json/genesis.json /root/.lava/config/genesis.json
COPY --from=builder /go/bin/cosmovisor /usr/local/bin/cosmovisor
COPY --from=builder /tmp/cosmovisor-upgrades /root/.lava/cosmovisor/

ENTRYPOINT ["cosmovisor"]
CMD ["--help"]