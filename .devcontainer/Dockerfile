# Copyright (c) 2021 Tailscale Inc & AUTHORS All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM mcr.microsoft.com/vscode/devcontainers/universal:linux as builder
USER root

# Magic DNS in a container where /etc/resolv.conf is a bind mount needed
# extra support, currently on a development branch.
WORKDIR /go/src/tailscale
COPY . ./
RUN git clone https://github.com/tailscale/tailscale.git && cd tailscale && \
    go mod download && \
    go install -mod=readonly ./cmd/tailscaled ./cmd/tailscale
COPY . ./

FROM mcr.microsoft.com/vscode/devcontainers/universal:linux
USER root

RUN apt-get update && apt-get install -y curl gpg dnsutils
COPY tailscaled /etc/init.d
COPY --from=builder /go/bin/tailscaled /usr/sbin/tailscaled
COPY --from=builder /go/bin/tailscale /usr/bin/tailscale

RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale
