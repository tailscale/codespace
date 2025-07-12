#!/usr/bin/env bash
# Copyright (c) 2025 Tailscale Inc & AUTHORS All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# This script handles Tailscale authentication during postCreateCommand
# when GitHub Codespaces secrets are guaranteed to be available

if [[ $(id -u) -ne 0 ]]; then
  if ! command -v sudo > /dev/null; then
    >&2 echo "tailscale auth setup could not run as root."
    exit 1
  fi
  exec sudo --non-interactive -E "$0" "$@"
fi

# Move the auth key to a non-exported variable so it is not leaking into child
# process environments.
auth_key="$TS_AUTH_KEY"
unset TS_AUTH_KEY

TAILSCALED_SOCK=/var/run/tailscale/tailscaled.sock

# Wait for tailscaled to be ready (it should be running from entrypoint)
count=100
while ((count--)); do
  [[ -S $TAILSCALED_SOCK ]] && break
  sleep 0.1
  
  if ((count == 0)); then
    >&2 echo "ERROR: tailscaled socket not found. Is tailscaled running?"
    exit 1
  fi
done

# Check if already authenticated
if /usr/local/bin/tailscale status --json >/dev/null 2>&1; then
  # Already authenticated, check if it's working
  if /usr/local/bin/tailscale status --json | grep -q '"BackendState":"Running"'; then
    echo "Tailscale is already running and authenticated"
    exit 0
  fi
fi

# Authenticate with auth key if available
if [[ -n "$auth_key" ]]; then
  if [[ "$auth_key" == "test-auth-key" ]]; then
    # Special test case
    touch /tmp/test-auth-key-seen
    echo "Test auth key detected"
  else
    echo "Authenticating Tailscale with auth key..."
    hostnamearg=""
    if [[ -n "${CODESPACE_NAME}" ]]; then
      hostnamearg="--hostname=${CODESPACE_NAME}"
    fi
    
    if /usr/local/bin/tailscale up --accept-routes --authkey="$auth_key" $hostnamearg; then
      echo "Tailscale authentication successful"
    else
      >&2 echo "ERROR: Tailscale authentication failed"
      exit 1
    fi
  fi
else
  echo "Tailscale is running. To authenticate, run: sudo tailscale up --accept-routes"
fi