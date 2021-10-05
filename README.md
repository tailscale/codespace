# Codespace with Tailscale connectivity
This repository contains a simple [codespace devcontainer](https://github.com/features/codespaces)
which can connect the running VM to a [Tailscale network](https://tailscale.com). To use it
you need to be a member of a GitHub Organization which has Codespaces enabled. When you
click on the Code button you should see a second tab with an option to start up
a new codespace.

![Start a new codespace](codespace.jpg)

You need to create a [Reusable Authkey](https://login.tailscale.com/admin/settings/authkeys)
for your Tailnet and add it as a [Codespaces Secret](https://github.com/settings/codespaces)
named `TAILSCALE_AUTHKEY`.

Then launch your codespace!
