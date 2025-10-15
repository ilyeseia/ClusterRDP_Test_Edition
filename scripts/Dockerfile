# File: Dockerfile.tailscale
FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y curl gnupg lsb-release iproute2 iptables sudo && \
    curl -fsSL https://tailscale.com/install.sh | sh

CMD ["sleep", "infinity"]
