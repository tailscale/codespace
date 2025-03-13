#!/usr/bin/env bash
# Copyright (c) 2022 Tailscale Inc & AUTHORS All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

/usr/local/sbin/tailscaled-devcontainer-start

unset TS_AUTH_KEY

exec "$@"
