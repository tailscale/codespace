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

check "tailscale operator is set" bash -c 'tailscale debug prefs | grep -q OperatorUser'

reportResults
