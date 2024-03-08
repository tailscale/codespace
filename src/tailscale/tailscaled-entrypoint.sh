#!/usr/bin/env bash
# Copyright (c) 2022 Tailscale Inc & AUTHORS All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -euxo pipefail

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
    --port=41641 &
elif command -v sudo > /dev/null; then
  sudo --non-interactive mkdir -p /workspaces/.tailscale
  2>/dev/null >/dev/null \
    sudo --non-interactive "TS_DEBUG_FIREWALL_MODE=$TS_DEBUG_FIREWALL_MODE" \
    /usr/local/sbin/tailscaled \
    --statedir=/workspaces/.tailscale/ \
    --socket=/var/run/tailscale/tailscaled.sock \
    --port=41641 &
else
  >&2 echo "tailscaled could not start as root."
fi
unset TS_DEBUG_FIREWALL_MODE

exec "$@"
