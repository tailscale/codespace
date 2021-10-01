# Codespace with Tailscale connectivity
This repository contains a simple [codespace devcontainer](https://github.com/features/codespaces)
which can connect the running VM to a [Tailscale network.](https://tailscale.com). To use it,
create a [Reusable Authkey](https://login.tailscale.com/admin/settings/authkeys) for your Tailnet
and add it as a [Codespaces Secret](https://github.com/settings/codespaces) named
`TAILSCALE_AUTHKEY`
