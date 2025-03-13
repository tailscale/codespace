#!/usr/bin/env bash
# Copyright (c) 2022 Tailscale Inc & AUTHORS All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -xeuo pipefail

export DEBIAN_FRONTEND=noninteractive

platform=$(uname -m)
if [ "$platform" = "x86_64" ]; then
    tailscale_url="https://pkgs.tailscale.com/stable/tailscale_${VERSION}_amd64.tgz"
elif [ "$platform" = "aarch64" ] || [ "$platform" = "arm64" ]; then
    tailscale_url="https://pkgs.tailscale.com/stable/tailscale_${VERSION}_arm64.tgz"
else
    echo "Unsupported platform: $platform"
    exit 1
fi

CURL_INSTALL_ATTEMPTED=""
install_curl() {
  CURL_INSTALL_ATTEMPTED=1

  if type apt-get > /dev/null 2>/dev/null; then
    apt-get update
    # install recommends left on so we get ca-certificates.
    apt-get -y install curl
  elif type microdnf > /dev/null 2>/dev/null; then
    microdnf makecache
    microdnf -y install --refresh --best --nodocs --noplugins --setopt=install_weak_deps=0 curl
  elif type dnf > /dev/null 2>/dev/null; then
    dnf check-update
    dnf -y install --refresh --best --nodocs --noplugins --setopt=install_weak_deps=0 curl
  elif type yum > /dev/null 2>/dev/null; then
    yum -y install --noplugins --setopt=install_weak_deps=0 curl
  elif type apk > /dev/null 2>/dev/null; then
    apk add curl
  else
    2> echo "Unknown platform, can not automate curl install. curl is required to download tailscale"
    return 1
  fi
}

download() {
  if command -v curl &> /dev/null; then
    curl -fsSL "$@"
  elif command -v wget &> /dev/null; then
    wget -qO - "$@"
  else
    if [[ -z "$CURL_INSTALL_ATTEMPTED" ]]; then
      install_curl >&2
      download "$@"
    else
      echo "Must install curl or wget to download $1" >&2
      return 1
    fi
  fi
}

script_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
scratch_dir="/tmp/tailscale"
mkdir -p "$scratch_dir"
trap 'rm -rf "$scratch_dir" /var/lib/apt/lists/*' EXIT

download "$tailscale_url" | tar -xzf - --strip-components=1 -C "$scratch_dir"
install -D -m 755 "$scratch_dir/tailscale" /usr/local/bin/tailscale
install -D -m 755 "$scratch_dir/tailscaled" /usr/local/sbin/tailscaled
install -D -m 755 "$script_dir/tailscaled-entrypoint.sh" /usr/local/sbin/tailscaled-entrypoint
install -D -m 755 "$script_dir/tailscaled-devcontainer-start.sh" /usr/local/sbin/tailscaled-devcontainer-start

mkdir -p /var/lib/tailscale /var/run/tailscale /var/log
touch /var/log/tailscaled.log

if ! command -v iptables >& /dev/null; then
  if command -v apt-get >& /dev/null; then
    apt-get update
    apt-get install -y --no-install-recommends iptables
  else
    >&2 echo "WARNING: iptables not installed. tailscaled might fail."
  fi
fi
