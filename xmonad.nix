{ config, pkgs, lib, home-manager, ... }:

let cfg = config.xsession.local-xmonad;
in {
  imports = [ home-manager.nixosModules.default ];

  options.xsession.local-xmonad = {
    useHiDPI = lib.mkOption {
      default = false;
      example = "true";
      type = lib.types.bool;
      description = "Whether to configure XMonad for HiDPI screens or not";
    };
  };

  config = {
    # Packages needed for my XMonad setup
    home-manager.users.jassob = {
      home.packages = with pkgs; [
        feh
        gnome-screenshot
        i3lock
        imagemagick
        libnotify
        networkmanagerapplet
        pavucontrol
        picom
        pulsemixer
        scrot
        trayer
        haskellPackages.xmobar
        xorg.xmessage
      ];

      # Appearance for GTK apps
      gtk.enable = true;
      gtk.cursorTheme.name = "Vanilla-DMZ";
      gtk.cursorTheme.package = pkgs.vanilla-dmz;
      gtk.cursorTheme.size = if cfg.useHiDPI then 32 else 16;
      gtk.font.package = pkgs.dejavu_fonts;
      gtk.font.name = "DejaVu Sans";
      gtk.iconTheme.package = pkgs.adwaita-icon-theme;
      gtk.iconTheme.name = "Adwaita";
      gtk.theme.package = pkgs.adapta-gtk-theme;
      gtk.theme.name = "Adapta-Eta";

      # Set GTK (Gnome) desktop portal as the default
      xdg.portal = {
        enable = true;
        config = {
          common = {
            default = [ "gtk" ];
          };
        };
        extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
      };

      services.dunst = {
        enable = true;
        settings = {
          global = {
            font = "Hasklig 12";
            # allow Pango markup
            markup = "full";
            # slight transparency if composer is run
            transparency = 5;
            # don't timeout notifications if idle for more than 2 min
            idle_threshold = 120;
            # show notifications on monitor with keyboard focus
            follow = "keyboard";
            dmenu = "${pkgs.rofi}/bin/rofi -dmenu -p dunst:";
            browser = "${pkgs.firefox}/bin/firefox";
            # Keyboard shortcuts
            close = "ctrl+space";
            close_all = "ctrl+shift+space";
            history = "ctrl+section";
            context = "ctrl+shift+period";
          };
          # Urgencies, colors taken from
          # https://github.com/lighthaus-theme/dunst
          urgency_low = {
            frame_color = "#1D918B";
            foreground = "#FFEE79";
            background = "#18191E";
            timeout = 5;
          };
          urgency_normal = {
            frame_color = "#D16BB7";
            foreground = "#FFEE79";
            background = "#18191E";
            timeout = 10;
          };
          urgency_critical = {
            frame_color = "#FC2929";
            foreground = "#FFFF00";
            background = "#18191E";
            timeout = 0;
          };
          # Custom rules
          disturb = {
            summary = "*dunst...*";
            urgency = "low";
          };
        };
      };

      # X11 composition
      services.picom.enable = true;

      services.sxhkd = {
        enable = true;
        keybindings = {
          "{XF86AudioLowerVolume, ctrl + F11}" = ''
          pulsemixer --change-volume -5 && notify-send "Volume: $(pulsemixer --get-volume | cut -d ' ' -f 1)%"'';

          "{XF86AudioRaiseVolume, ctrl + F12}" = ''
          pulsemixer --change-volume +5 && notify-send "Volume: $(pulsemixer --get-volume | cut -d ' ' -f 1)%"'';

          "{XF86AudioMute, ctrl + F10}" = ''
          pulsemixer --toggle-mute && notify-send "Muted: $(\
               if [[ $(pulsemixer --get-mute | cut -d ' ' -f 1) == 0 ]]; \
                      then echo No; \
                      else echo Yes; \
               fi)"'';

          "{XF86MonBrightnessUp, ctrl + F6}" = ''
          light -A 5 && notify-send "Brightness: $(light | cut -f 1 -d .)%"'';

          "{XF86MonBrightnessDown, ctrl + F5}" = ''
          light -U 5 && notify-send "Brightness: $(light | cut -f 1 -d .)%"'';

          "XF86Audio{Pause,Play,Next,Prev}" =
            "${pkgs.playerctl}/bin/playerctl {pause,play,next,previous}";
          "XF86KbdBrightness{Up,Down}" =
            "asus_kbd_backlight {increase,decrease}";
          "super + x; o" = "${pkgs.rofi}/bin/rofi -show drun";
          "super + x; f" = ''$HOME/.local/bin/openfile -i "rofi -dmenu"'';
          "super + p" = "rofi-pass";
          "super + x ; e ; c" = ''emacsclient -c -e "(org-capture)"'';
          "super + x; r" = "rofi -show emoji";
          "super + e" = ''
          $HOME/dotfiles/jassob/.local/bin/startemacs -i "rofi -dmenu -p Emacs"'';
          "super + x; l" = "i3lock && sleep 5s; xset dpms force suspend";
          "super + x; L" = "i3lock && systemctl suspend";
          "super + x; p" =
            "${pkgs.scrot}/bin/scrot -u -e 'mv $f ~/Pictures/screenshots/'";
          "super + x; P" =
            "exec import -window root png:$HOME/Pictures/screenshots/screenshot_$(date +%F_%H-%M-%S).png";
          # make sxhkd reload its configuration files:
          "super + Escape" = "pkill -USR1 -x sxhkd";
        };
      };

      xsession = {
        enable = true;
        windowManager.xmonad = {
          enable = true;
          config = ./files/XMonad.hs;
          enableContribAndExtras = true;
          extraPackages = hpkgs: [
            hpkgs.xmonad-contrib
            hpkgs.xmonad-extras
            hpkgs.xmobar
          ];
        };

        initExtra = ''
          # Set correct keyboard layout
          setxkbmap se -model emacs2 -option ctrl:nocaps
        '';

        profileExtra = ''
          # Restore last wallpaper
          if [ -f "$''${HOME}"/.fehbg ]; then
             $''${HOME}/.fehbg
          else
             systemctl start --user dwall.service
          fi
          # Launch hotkey daemon (and make it detect keymap changes)
          ${pkgs.sxhkd}/bin/sxhkd -m -1 & disown %1
        '';
      };
    };

    # Making sure to remove files generated by Nix before rebuilding
    # home-manager generation
    systemd.services.home-manager-jassob.preStart = ''
    if [ -f /home/jassob/.xmonad/xmonad-x86_64-linux ]; then
      rm -f /home/jassob/.xmonad/xmonad-x86_64-linux
    fi
  '';
  };
}
