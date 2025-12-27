{ config, pkgs, home-manager, ... }:

let
  username = "jassob";

  # Used for both Bash and ZSH
  shellProfileExtra = ''
    # Add locally installed binaries to PATH
    [ -d $HOME/.local/bin ] && PATH=$HOME/.local/bin:$PATH
    [ -d $HOME/.cargo/bin ] && PATH=$HOME/.cargo/bin:$PATH
    [ -d $HOME/go/bin ] && PATH=$HOME/go/bin:$PATH

    if [ -f "~/.xsessionrc" ]; then . ~/.xsessionrc; fi
  '';

  sessionVariables = {
    # Only show the last two directories in current path
    PROMPT_DIRTRIM = "2";
    # Override default script directory
    SD_ROOT = "/home/${username}/scripts";
    # Set EDITOR to emacsclient
    EDITOR = "${pkgs.emacs}/bin/emacsclient -nw";
  };

in
{
  imports = [ home-manager.nixosModules.default ];

  # Allow users to update binary cache settings
  nix.settings = { trusted-users = [ username ]; };

  users.users.${username} = {
    description = "Jacob Jonsson";
    isNormalUser = true;
    extraGroups = [
      "adbusers" # android development
      "adm" # group useful for sudo permissions
      "wheel" # visible in login screen
      "docker" # allowed to control docker daemon
      "networkmanager" # allowed to control system networking
      "video" # allowed to control graphics card
      "wireshark" # allowed to listen in on network traffic
    ];
    uid = 1000;
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.jassob = {
      home.file = {
        ".shell/aliases".source = ./files/shell_aliases;
        ".mbsyncrc".source = ./files/mbsyncrc;
      };

      manual.html.enable = true;
      xdg.enable = true;

      programs.bash = {
        enable = true;
        enableVteIntegration = true;
        historyControl = [ "ignoredups" "ignorespace" ];
        historyFile = "/home/${username}/.shell/history";
        sessionVariables = sessionVariables // {
          # Update shell history on every command
          PROMPT_COMMAND = "history -a;$PROMPT_COMMAND";
        };
        profileExtra = shellProfileExtra;
        initExtra = ''
          PROMPT_COLOR=$(echo 33 34 32 36 35 | ${pkgs.findutils}/bin/xargs ${pkgs.coreutils}/bin/shuf -n 1 -e)
          PS1="\[\e[''${PROMPT_COLOR}m\]\w\[\e[00m\] \$ "
          # Source shell aliases
          . $HOME/.shell/aliases
          # Source secrets
          [ -f ~/.shell/secrets ] && . ~/.shell/secrets || true
        '';
      };

      programs.zsh = {
        enable = true;
        defaultKeymap = "emacs";
        enableCompletion = true;
        history = {
          path = "/home/${username}/.shell/history";
          ignoreDups = true;
          share = true;
        };
        sessionVariables = sessionVariables;
        profileExtra = ''
          ${shellProfileExtra}
          # Add keybindings
          bindkey '^T' transpose-chars
          bindkey '[T' transpose-words
          bindkey '^X^A^F' fzf-file-widget
          # Add keybindings from /etc/inputrc
          bindkey "\e[1~" beginning-of-line
          bindkey "\eOH" beginning-of-line
          bindkey "\e[H" beginning-of-line
          bindkey "\e[5~" beginning-of-history
          bindkey "\e[6~" end-of-history
          bindkey "\e[4~" end-of-line
          bindkey "\e[8~" end-of-line
          bindkey "\eOF" end-of-line
          bindkey "\e[F" end-of-line
          bindkey "\e[3~" delete-char
          bindkey "\e[2~" quoted-insert
          bindkey "\e[5C" forward-word
          bindkey "\e[1;5C" forward-word
          bindkey "\e[5D" backward-word
          bindkey "\e[1;5D" backward-word
        '';
        initContent = ''
          PROMPT_COLOR=$(echo yellow blue green cyan magenta | ${pkgs.findutils}/bin/xargs ${pkgs.coreutils}/bin/shuf -n 1 -e)
          PROMPT="%B%F{$PROMPT_COLOR}%}%3~%f%b%f%F{white} %# %f";
          # Source .shell/aliases
          . ~/.shell/aliases
          # Source .shell/secrets
          [ -f ~/.shell/secrets ] && . ~/.shell/secrets || true
          # Setup script-directory zsh completion
          fpath+="${pkgs.script-directory}/share/zsh/site-functions"
          if [[ $TERM == dumb || $TERM == emacs || ! -o interactive ]]; then
              unsetopt zle
              unset zle_bracketed_paste
              export PS1='%m %~ $ '
          fi
        '';
      };

      programs.direnv.enable = true;
      programs.direnv.enableBashIntegration = true;
      programs.direnv.enableZshIntegration = true;
      programs.direnv.nix-direnv = {
        enable = true;
        package = pkgs.nix-direnv;
      };

      programs.eza.enable = true;

      programs.fzf.enable = true;
      programs.fzf.enableBashIntegration = true;
      programs.fzf.enableZshIntegration = true;

      programs.z-lua.enable = true;
      programs.z-lua.enableAliases = true;
      programs.z-lua.enableBashIntegration = true;
      programs.z-lua.enableZshIntegration = true;

      programs.git.enable = true;
      programs.git.signing = {
        key = "D822DFB8049AF39ADF43EA0A7E30B9B047F7202E";
        signByDefault = true;
      };
      programs.git.settings = {
        user.name = "Jacob Jonsson";
        user.email = "jacob.t.jonsson@gmail.com";

        alias = {
          amend = "commit --amend -C HEAD";
          fp = "push --force-with-lease";
          sha = "rev-parse --short HEAD";
        };

        github.user = "Jassob";
        pull.rebase = true;
        rebase.autosquash = true;
        rebase.autostash = true;
        rebase.updateRefs = true;
        rerere.enabled = true;

        url."ssh://git@github.com/einride/".insteadOf =
          "https://github.com/einride/";
        url."ssh://git@github.com/einride-autonomous/".insteadOf =
          "https://github.com/einride-autonomous/";
      };

      programs.jujutsu.enable = true;
      programs.jujutsu.package = pkgs.unstable.jujutsu;
      programs.jujutsu.settings = {
        user.name = "Jacob Jonsson";
        user.email = "jacob.t.jonsson@gmail.com";
        aliases.tug- = [ "bookmark" "move" "--from" "heads(::@- & bookmarks())" "--to" "@-" ];
        aliases.tug = [ "bookmark" "move" "--from" "heads(::@- & bookmarks())" "--to" "@" ];
      };

      programs.command-not-found.enable = false;
      programs.nix-index.enable = true;
      programs.nix-index.enableBashIntegration = false;
      programs.nix-index.enableZshIntegration = false;

      programs.script-directory.enable = true;
      programs.script-directory.settings.SD_ROOT = "/home/${username}/scripts";

      # Setup Emacs base package and enable it as a user service.
      programs.emacs.enable = true;
      programs.emacs.extraPackages = epkgs: [
        epkgs.pdf-tools
        epkgs.org-pdftools
        epkgs.tree-sitter-langs
        epkgs.tree-sitter
        epkgs.treesit-grammars.with-all-grammars
      ];
      services.emacs.enable = true;
      services.emacs.client.enable = true;
      services.emacs.socketActivation.enable = true;

      # GPG
      programs.gpg.enable = true;
      programs.gpg.settings = {
        keyserver = "hkps://hkps.pool.sks-keyservers.net";
        keyserver-options = "no-honor-keyserver-url";
        keyid-format = "0xlong";
      };
      services.gpg-agent.enable = true;
      services.gpg-agent.enableSshSupport = true;
      services.gpg-agent.extraConfig = ''
        allow-emacs-pinentry
        enable-ssh-support
      '';
      services.gpg-agent.sshKeys = [
        # Private key
        "31FFDEC76903AFE64324FA2FAF64B6C07CAB091A"
      ];
    };
  };
}
