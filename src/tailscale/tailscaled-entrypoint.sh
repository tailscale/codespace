#!/usr/bin/env bash
# Copyright (c) 2022 Tailscale Inc & AUTHORS All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

check_userspace() {
  if [[ ! -c /dev/net/tun ]]; then
    >&2 cat - <<-EOF
Error: /dev/net/tun is missing and could not be created!

taiilscaled will fail to start.

You can start tailscaled manually in userspace mode, see:
  https://tailscale.com/kb/1112/userspace-networking
EOF
  fi
}

# Note: It is not recommended that users copy this setting into other
# environments, the feature is in test and will be formally released in the
# future, debug flags may later be recycled for other purposes leading to
# unexpected behavior.
export TS_DEBUG_FIREWALL_MODE=auto
TAILSCALED_PID=""
TAILSCALED_SOCK=/var/run/tailscale/tailscaled.sock
TAILSCALED_LOG=/var/log/tailscaled.log
if [[ "$(id -u)" -eq 0 ]]; then
  if [[ ! -c /dev/net/tun ]]; then
    mkdir -p /dev/net
    mknod /dev/net/tun c 10 200
  fi
  check_userspace
  mkdir -p /workspaces/.tailscale /var/log
  touch $TAILSCALED_LOG
  >$TAILSCALED_LOG 2>&1 \
    /usr/local/sbin/tailscaled \
    --statedir=/workspaces/.tailscale/ \
    --socket=$TAILSCALED_SOCK \
    --port=41641 &
  TAILSCALED_PID=$!
elif command -v sudo > /dev/null; then
  if [[ ! -c /dev/net/tun ]]; then
    sudo --non-interactive mkdir -p /dev/net
    sudo --non-interactive mknod /dev/net/tun c 10 200
  fi
  check_userspace
  sudo --non-interactive mkdir -p /workspaces/.tailscale /var/log
  sudo --non-interactive touch $TAILSCALED_LOG
  >$TAILSCALED_LOG 2>&1 \
    sudo --non-interactive "TS_DEBUG_FIREWALL_MODE=$TS_DEBUG_FIREWALL_MODE" \
    /usr/local/sbin/tailscaled \
    --statedir=/workspaces/.tailscale/ \
    --socket=$TAILSCALED_SOCK \
    --port=41641 &
  TAILSCALED_PID=$!
else
  >&2 echo "tailscaled could not start as root."
fi
unset TS_DEBUG_FIREWALL_MODE

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

exec "$@"
