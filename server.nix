{ config, lib, pkgs, ... }:

{
  # Firewall
  networking.firewall.allowedTCPPorts = [
    8001 # Weechat Relay (as configured in ~/.weechat/relay.conf)
    8081 # AdGuard Home admin page
    80 443 # Web ports
  ];

  # IRC stuff
  environment.systemPackages = [ pkgs.weechat ];
  services.bitlbee.enable = true;
  services.bitlbee.authBackend = "pam";
  services.bitlbee.authMode = "Open";
  services.bitlbee.libpurple_plugins = with pkgs.pidginPackages; [
    # tdlib-purple
    purple-discord
  ];
  services.bitlbee.plugins = [ pkgs.bitlbee-facebook ];

  # Git stuff
  users.groups.git = { };
  users.users.git = {
    description = "Git system user";
    isSystemUser = true;
    group = "git";
    home = "/var/lib/forgejo";
    shell = pkgs.bashInteractive;
  };

  services.forgejo.enable = true;
  services.forgejo.user = "git";
  services.forgejo.group = "git";
  services.forgejo.lfs.enable = true;
  services.forgejo.repositoryRoot = "/mnt/media/home/git/repositories";
  services.forgejo.settings = {
    DEFAULT.APP_NAME = "Jassob's Git server";

    mailer.ENABLED = false;

    repository.DISABLE_HTTP_GIT = true;

    server.HTTP_PORT = 3000;
    server.HTTP_ADDR = "127.0.0.1";
    server.ROOT_URL = "https://git.jassob.se";
    server.SSH_DOMAIN = "git.jassob.se";
    server.SSH_PORT = 222;

    session.COOKIE_SECURE = true;

    service.DISABLE_REGISTRATION = true;
  };

  # SSH
  services.openssh.enable = true;
  services.openssh.settings = {
    # Only allow pub keys
    PasswordAuthentication = false;
    PubkeyAuthentication = true;
    UsePAM = true;
  };

  # Ad blocking
  services.adguardhome.enable = true;
  services.adguardhome.port = 8081;

  # Certificates
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "jacob.t.jonsson@gmail.com";
  security.acme.defaults.enableDebugLogs = true;

  # Setup web servers.
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };
  services.nginx.virtualHosts = {
    "git.jassob.se" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
      };
    };
    "jassob.se" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        root = "/var/www/html/jassob.se";
      };
    };
    "gpgj.se" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        root = "/var/www/html/gpgj.se";
      };
    };
  };
}
