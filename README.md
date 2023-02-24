# Dev Container Feature for Tailscale connectivity

This repository contains a feature for [Development Containers](https://containers.dev) (such as [GitHub Codespaces](https://github.com/features/codespaces))
to connect the running VM to a [Tailscale network](https://tailscale.com).

## Usage

To get started, add the following [feature](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-features-to-a-devcontainer-file)
to your `devcontainer.json`:

```jsonc
{
  // ...
  "runArgs": ["--device=/dev/net/tun"],
  "features": {
    "ghcr.io/tailscale/codespace/tailscale": {}
  }
}
```

Then launch your Dev Container.

![Start a new codespace](codespace.jpg)

After it starts up, run [`tailscale up`](https://tailscale.com/kb/1080/cli/#up):

```shell
sudo tailscale up --accept-routes
```

You'll only need to run `tailscale up` once per Codespace.
The Tailscale state will be saved between rebuilds.
