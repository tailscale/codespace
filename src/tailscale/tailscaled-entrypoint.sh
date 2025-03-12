#!/usr/bin/env bash
# Copyright (c) 2022 Tailscale Inc & AUTHORS All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -euxo pipefail

USERSPACE_SOCKS_FLAGS=""
if [[ ! -f /dev/net/tun ]]; then
    >&2 echo "/dev/net/tun is missing, attempting to create it"
    if mknod /dev/net/tun c 10 200; then
        >&2 echo "Successfully created /dev/net/tun"
    else
        >&2 cat - <<-EOF
Warning: /dev/net/tun is missing and could not be created.

    Tailscaled will start in userspace-mode.
    A SOCKS proxy will start at localhost:1055.

    For more information on userspace-mode networking, see:
        https://tailscale.com/kb/1112/userspace-networking

To enable /dev/net/tun, add one of the following to devcontainer.json:

    "runArgs": ["--device=/dev/net/tun"]

or:

    "mounts": [
        {
            "source": "/dev/net/tun",
            "target": "/dev/net/tun",
            "type": "bind"
        }
    ]
EOF
    fi
    # Note: do not quote during expansion.
    USERSPACE_SOCKS_FLAGS="--tun=userspace-networking --socks5-server=localhost:1055 --outbound-http-proxy-listen=localhost:1055"
    export ALL_PROXY=socks5://localhost:1055/
    export HTTP_PROXY=http://localhost:1055/
    export http_proxy=http://localhost:1055/
fi

# Note: It is not recommended that users copy this setting into other
# environments, the feature is in test and will be formally released in the
# future, debug flags may later be recycled for other purposes leading to
# unexpected behavior.
export TS_DEBUG_FIREWALL_MODE=auto
if [[ "$(id -u)" -eq 0 ]]; then
  mkdir -p /workspaces/.tailscale || true
  2>/dev/null >/dev/null \
    /usr/local/sbin/tailscaled \
    --statedir=/workspaces/.tailscale/ \
    --socket=/var/run/tailscale/tailscaled.sock \
    --port=41641 \
    $USERSPACE_SOCKS_FLAGS \
    &
elif command -v sudo > /dev/null; then
  sudo --non-interactive mkdir -p /workspaces/.tailscale
  2>/dev/null >/dev/null \
    sudo --non-interactive "TS_DEBUG_FIREWALL_MODE=$TS_DEBUG_FIREWALL_MODE" \
    /usr/local/sbin/tailscaled \
    --statedir=/workspaces/.tailscale/ \
    --socket=/var/run/tailscale/tailscaled.sock \
    --port=41641 \
    $USERSPACE_SOCKS_FLAGS \
    &
else
  >&2 echo "tailscaled could not start as root."
  if [[ -n "${USERSPACE_SOCKS_FLAGS}" ]]; then
      unset ALL_PROXY
      unset HTTP_PROXY
      unset http_proxy
  fi
fi
unset TS_DEBUG_FIREWALL_MODE

exec "$@"
