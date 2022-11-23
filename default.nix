{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.senpro.oci-containers.file-server;

in

{

  options = {
    senpro.oci-containers.file-server = {
      file-server = {
        traefik.fqdn = mkOption {
          type = types.str;
          default = "file-server.local";
          example = "file-server.example.com";
          description = ''
            Defines the FQDN under which the predefined container endpoint should be reachable.
          '';
        };
      };
    };
  };

  config = {
    virtualisation.oci-containers.containers = {
      file-server = {
        image = "docker.io/halverneus/static-file-server:latest";
        extraOptions = [
          "--net=proxy"
        ];
        volumes = [
          "file-server:/web"
        ];
        environment = {
          SHOW_LISTING = "false";
        };
        autoStart = true;
      };
    };
    systemd.services = {
      "podman-file-server" = {
        postStart = ''
          ${pkgs.coreutils-full}/bin/printf '%s\n' "http:" \
          "  routers:"   \
          "    file-server:" \
          "      rule: \"Host(\`${cfg.file-server.traefik.fqdn}\`)\"" \
          "      service: \"file-server\"" \
          "      entryPoints:" \
          "      - \"https2-tcp\"" \
          "      tls: true" \
          "  services:" \
          "    file-server:" \
          "      loadBalancer:" \
          "        passHostHeader: true" \
          "        servers:" \
          "        - url: \"http://file-server:8080\"" > $(${pkgs.podman}/bin/podman volume inspect traefik --format "{{.Mountpoint}}")/conf.d/apps-file-server.yml
        '';
      };
    };
  };

}
