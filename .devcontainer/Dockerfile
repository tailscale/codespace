# Copyright (c) 2020 Tailscale Inc & AUTHORS All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM mcr.microsoft.com/vscode/devcontainers/universal:linux

USER root

COPY tailscaled /etc/init.d

RUN apt update && apt install -y curl gpg

RUN curl https://pkgs.tailscale.com/stable/ubuntu/focal.gpg | apt-key add
RUN curl https://pkgs.tailscale.com/stable/ubuntu/focal.list | tee /etc/apt/sources.list.d/tailscale.list
RUN apt update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt -y install --no-install-recommends tailscale
RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale
