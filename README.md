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

## Starting Tailscale

The Tailscale daemon starts automatically as part of the devcontainer entrypoint.

### Manual Log in

```shell
sudo tailscale up --accept-routes
```

More info: [`tailscale up`](https://tailscale.com/kb/1080/cli/#up)

### Automatic login

Create an [auth key](https://tailscale.com/kb/1085/auth-keys) in the Tailscale
[admin panel](https://login.tailscale.com/admin/settings/keys).

Create a codespace secret called `TS_AUTH_KEY` in your
[codespaces configuration](https://github.com/settings/codespaces) containing
the auth key you made above.

Now whenever you launch a devcontainer with access to this secret, it will
automatically perform a `tailscale up --accept-routes --auth-key=$TS_AUTH_KEY`.

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