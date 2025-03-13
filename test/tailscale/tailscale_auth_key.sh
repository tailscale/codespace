#!/usr/bin/env bash
# Copyright (c) 2025 Tailscale Inc & AUTHORS All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -e

source dev-container-features-test-lib

# Wait for the auth key to be seen by the start script.
count=100
while ((count--)); do
    [[ -f /tmp/test-auth-key-seen ]] && break
    sleep 0.1
done

check "/tmp/test-auth-key-seen" ls /tmp/test-auth-key-seen

# It would be nice to directly test that the entrypoint is doing unset
# TS_AUTH_KEY, however that isn't visible to the test execution.

reportResults