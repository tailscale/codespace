#!/usr/bin/env bash
# Copyright (c) 2022 Tailscale Inc & AUTHORS All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -euo pipefail

platform=$(uname -m)
if [ "$platform" = "x86_64" ]; then
    tailscale_url="https://pkgs.tailscale.com/stable/tailscale_${VERSION}_amd64.tgz"
elif [ "$platform" = "aarch64" ] || [ "$platform" = "arm64" ]; then
    tailscale_url="https://pkgs.tailscale.com/stable/tailscale_${VERSION}_arm64.tgz"
else
    echo "Unsupported platform: $platform"
    exit 1
fi

download() {
  if command -v curl &> /dev/null; then
    curl -fsSL "$1"
  elif command -v wget &> /dev/null; then
    wget -qO - "$1"
  else
    echo "Must install curl or wget to download $1" 1&>2
    return 1
  fi
}

script_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
scratch_dir="/tmp/tailscale"
mkdir -p "$scratch_dir"
trap 'rm -rf "$scratch_dir"' EXIT

download "$tailscale_url" |
  tar -xzf - --strip-components=1 -C "$scratch_dir"
install -D "$scratch_dir/tailscale" /usr/local/bin/tailscale
install -D "$scratch_dir/tailscaled" /usr/local/sbin/tailscaled
install -D "$script_dir/tailscaled-entrypoint.sh" /usr/local/sbin/tailscaled-entrypoint

mkdir -p /var/lib/tailscale /var/run/tailscale

if ! command -v iptables >& /dev/null; then
  if command -v apt-get >& /dev/null; then
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends iptables
    rm -rf /var/lib/apt/lists/*
  else
    echo "WARNING: iptables not installed. tailscaled might fail."
  fi
fi
