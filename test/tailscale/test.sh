#!/bin/bash
# Copyright (c) 2025 Tailscale Inc & AUTHORS All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -e

source dev-container-features-test-lib

check "daemon is running" tailscale version --daemon

if [[ -n "$VERSION" ]]; then
    check "version is correct" bash -c "tailscale version --daemon | grep -q $VERSION"
fi

reportResults