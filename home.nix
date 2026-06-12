{ config, pkgs, ... }:

{
  home.username = "wslUser";
  home.homeDirectory = "/home/wslUser";

  home.stateVersion = "25.11";

  home.packages = [
    pkgs.git
    pkgs.gh
    pkgs.curl
    pkgs.mise
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".config/helix/yazi-picker.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        tmp="/tmp/yazi-chosen-$$"
        yazi --chooser-file="$tmp"

        if [[ -s "$tmp" ]]; then
            paths=$(cat "$tmp")

            if [[ "$paths" == search://* ]]; then
                paths=$(echo "$paths" | sed 's|search://[^/]*/||')
            fi

            rm -f "$tmp"
            zellij action toggle-floating-panes
            zellij action write 27
            zellij action write-chars ":open \"$paths\""
            zellij action write 13
        else
            rm -f "$tmp"
            zellij action toggle-floating-panes
        fi
      '';
    };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/wslUser/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
  };

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.bash = {
    enable = true;
    initExtra = ''
      eval "$(${pkgs.mise}/bin/mise activate bash)"
    '';
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.helix = {
    enable = true;
    settings = {
      keys.normal = {
        "C-y" = ":sh zellij run -n Yazi -c -f -x 10%% -y 10%% --width 80%% --height 80%% -- bash ~/.config/helix/yazi-picker.sh";
      };
    };
  };

  programs.yazi = {
    enable = true;
    settings = {
      opener = {
        edit = [
          { run = ''hx "$@"''; block = true; desc = "Helix"; }
        ];
      };
      open = {
        prepend_rules = [
          { mime = "*"; use = "edit"; }
        ];
      };
    };
  };

  programs.zellij = {
    enable = true;
  };

  # Enable Git and set user information
  programs.git = {
    enable = true;

    settings = {
      user.name = "Coxless";
      user.email = "201592128+Coxless@users.noreply.github.com";
      init.defaultBranch = "main";
      pull.rebase = true;
      credential.helper = "!gh auth git-credential";
    };
  };
}
