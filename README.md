# Codespace feature for Tailscale connectivity

This repository contains a feature for [GitHub Codespaces](https://github.com/features/codespaces)
to connect the running VM to a [Tailscale network](https://tailscale.com).

![Start a new codespace](codespace.jpg)

To get started, add the following [feature](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-features-to-a-devcontainer-file)
to your `devcontainer.json`:

```json
"features": {
  "ghcr.io/tailscale/codespace/tailscale": {
    "version": "latest"
  }
}
```

Then launch your Codespace. After it starts up, run [`tailscale up`](https://tailscale.com/kb/1080/cli/#up):

```shell
sudo tailscale up --accept-routes
```

You'll only need to run `tailscale up` once per Codespace.
The Tailscale state will be saved between rebuilds.

## Details

- A mount is added called `tailscale-${devcontainerId}` mapped to
  `/var/lib/tailscale` to persist taislcaled state across devcontainer rebuilds,
  so a single devcontainer will remain logged in for the devcontainer lifetime.
- The feature requires `CAP_NET_ADMIN` in order to configure certain network
  properties for kernel mode tailscale.
- The feature requires kernel tun support in the runtime and `CAP_MKNOD` so that
  it can create a tun device node if needed.
- `CAP_NET_RAW` enables the feature to send ICMP.

## Development

A convenient way to develop this feature is to use codespaces, as they start by
default with many of the dependencies required (at least Docker and npx).

Inside a codespace you can use the `Tasks:Run Test Task` command.

On a standalone machine tests can be run with:

```shell
npx @devcontainers/cli features test
```