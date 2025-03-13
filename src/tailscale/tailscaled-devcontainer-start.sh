#!/usr/bin/env bash
# Copyright (c) 2025 Tailscale Inc & AUTHORS All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

if [[ $(id -u) -ne 0 ]]; then
  if ! command -v sudo > /dev/null; then
    >&2 echo "tailscaled could not start as root."
    exit 1
  fi
  exec sudo --non-interactive -E "$0" "$@"
fi

if [[ ! -c /dev/net/tun ]]; then
  mkdir -p /dev/net
  mknod /dev/net/tun c 10 200
  if [[ ! -c /dev/net/tun ]]; then
    >&2 cat - <<-EOF
Error: /dev/net/tun is missing and could not be created!

taiilscaled will fail to start.

You can start tailscaled manually in userspace mode, see:
https://tailscale.com/kb/1112/userspace-networking
EOF
  fi
fi


TAILSCALED_PID=""
TAILSCALED_SOCK=/var/run/tailscale/tailscaled.sock
TAILSCALED_LOG=/var/log/tailscaled.log

# Note: TS_DEBUG_FIREWALL_MODE: it is not recommended that users copy this
# setting into other environments, the feature is in test and will be formally
# released in the future, debug flags may later be recycled for other purposes
# leading to unexpected behavior.
>$TAILSCALED_LOG 2>&1 TS_DEBUG_FIREWALL_MODE=auto /usr/local/sbin/tailscaled &
TAILSCALED_PID=$!

if [[ -n "$TAILSCALED_PID" ]]; then
  count=100
  while ((count--)); do
    [[ -f $TAILSCALED_SOCK ]] && break
    sleep 0.01

    if ! kill -0 "$TAILSCALED_PID"; then
      >&2 echo "ERROR: tailscaled exited during startup, logs follow:"
      >&2 cat $TAILSCALED_LOG
      break
    fi
  done
fi