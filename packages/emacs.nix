# Derivation for Emacs pre-configured with packages that I need.
#
# Stolen from: https://github.com/tazjin/nixos-config/blob/master/emacs.nix

{ pkgs }:

with pkgs; with emacsPackagesNg;
let emacsWithPackages = (emacsPackagesNgGen emacs).emacsWithPackages;

# As the EXWM-README points out, XELB should be built from source if
# EXWM is.
xelb = melpaBuild {
  pname = "xelb";
  ename = "xelb";
  version = "0.17";
  recipe = builtins.toFile "recipe" ''
    (xelb :fetcher github
    :repo "ch11ng/xelb")
  '';

  packageRequires = [ cl-generic emacs ];

  src = fetchTarball {
    url = "https://github.com/ch11ng/xelb/archive/0.17.tar.gz";
    sha256 = "094366n6k71bnsg79kk9hvwq6slq6a6a2amlmdmn3746lfqynsxg";
  };
};

# EXWM pinned to a newer version than what is released due to a
# potential fix for ch11ng/exwm#425.
exwm = melpaBuild {
  pname   = "exwm";
  ename   = "exwm";
  version = "0.22";
  recipe  = builtins.toFile "recipe" ''
    (exwm :fetcher github
    :repo "ch11ng/exwm")
  '';

  packageRequires = [ xelb ];

  src = fetchTarball {
    url = "https://github.com/ch11ng/exwm/archive/0.22.tar.gz";
    sha256 = "11wzgfhxgvb1s18ihmlga7m5wshg0rdrkaq30rknix5irl8zw64w";
  };
};

in emacsWithPackages (epkgs:
  # Actual ELPA packages (the enlightened!)
  (with epkgs.elpaPackages; [
    auctex
    auctex-latexmk
    company
    delight
    pinentry
    rainbow-mode
    undo-tree
  ]) ++
  # MELPA packages
  (with epkgs.melpaPackages; [
    ag
    cargo
    company-lsp
    dante
    dockerfile-mode
    evil
    evil-tutor
    forge
    git-gutter-plus
    go-mode
    gotest
    guide-key
    gruvbox-theme
    haskell-mode
    hl-todo
    jq-mode
    lsp-mode
    lsp-ui
    magit
    multiple-cursors
    nix-mode
    no-littering
    org-gcal
    paredit
    password-store
    pkgs.mu
    pkgs.notmuch
    projectile
    rainbow-delimiters
    rust-mode
    smart-mode-line
    smartparens
    smex
    toml-mode
    undo-tree
    use-package
    visual-fill-column
    writeroom-mode
    yaml-mode
    yasnippet
  ]) ++
  # Custom packaged Emacs packages:
  [ xelb exwm ]
)
