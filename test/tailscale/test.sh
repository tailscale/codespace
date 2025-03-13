#!/bin/bash
# Copyright (c) 2025 Tailscale Inc & AUTHORS All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -e

source dev-container-features-test-lib

if [[ "$VERSION" == latest ]]; then
    check "Daemon: " tailscale version --daemon
else
    check "$VERSION" tailscale version --daemon
fi

reportResults