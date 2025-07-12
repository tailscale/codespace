#!/usr/bin/env bash
# Copyright (c) 2025 Tailscale Inc & AUTHORS All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -e

source dev-container-features-test-lib

# The auth logic now runs in postCreateCommand, not entrypoint
# So we need to manually trigger it for testing
if [[ -f /usr/local/sbin/tailscaled-auth-setup ]]; then
    # Run the auth setup script directly since test framework
    # doesn't execute postCreateCommand
    TS_AUTH_KEY="test-auth-key" /usr/local/sbin/tailscaled-auth-setup || true
fi

# Wait for the auth key to be seen by the auth setup script.
count=100
while ((count--)); do
    [[ -f /tmp/test-auth-key-seen ]] && break
    sleep 0.1
done

check "/tmp/test-auth-key-seen" ls /tmp/test-auth-key-seen

# Verify the auth setup script exists
check "tailscaled-auth-setup exists" ls /usr/local/sbin/tailscaled-auth-setup

reportResults