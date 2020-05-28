FROM ubuntu:bionic as builder

SHELL ["/bin/bash", "-e", "-o", "pipefail", "-c"]

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y -q && \
    apt-get install -y --no-install-recommends build-essential bison flex libpcap-dev libc6-dev

COPY . /rpcapd
WORKDIR /rpcapd

RUN cd winpcap/wpcap/libpcap && chmod +x ./configure && chmod +x ./runlex.sh && ./configure && make
RUN make

FROM ubuntu:bionic

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y -q && \
    apt-get install -y --no-install-recommends libpcap0.8 libc6

COPY --from=builder /rpcapd/winpcap/wpcap/libpcap/rpcapd/rpcapd /usr/local/bin/rpcapd

ENTRYPOINT ["/usr/local/bin/rpcapd"]

