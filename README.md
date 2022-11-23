# file-server
Configuration snippet for NixOS to spin up a file-server container using Podman.

## :tada: `Getting started`

Add the following statement to your `imports = [];` in `configuration.nix` and do a `nixos-rebuild`:

```
  <path-to-default-nix> {
    senpro.oci-containers.file-server = {
      file-server = {
        traefik.fqdn = "<your-fqdn>";
      };
    };
  }
```
