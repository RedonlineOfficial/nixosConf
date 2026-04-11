{ self, inputs, ... }: let

  opts = "--color=always --noconfirm";

in {

  flake.nixosModules.zsh = { pkgs, ... }: {

    programs.zsh = {
      histSize = 10000;

      setOptions = [
        "AUTO_CD"
        "HIST_IGNORE_DUPS"
        "HIST_IGNORE_SPACE"
      ];

      shellAliases = {
        # --- Nixos ---
        rebuild = "sudo nixos-rebuild switch --flake ~/nixosConf#";
        # --- Zsh ---
        reload = "exec zsh";

        # --- Power ---
        shutdown = "sudo shutdown now";
        reboot   = "sudo reboot";

        # --- Navigation ---
        z = "cd";
        ".." = "cd ..";
        "2." = "cd ../..";
        "3." = "cd ../../..";
        "4." = "cd ../../../..";
        "5." = "cd ../../../../..";

        # --- File and Directory Handling ---
        mkd   = "mkdir -pv";
        cp    = "cp -ir";
        mv    = "mv -i";
        rm    = "rm -ir";
        grep  = "grep --color=auto";
        fgrep = "fgrep --color=auto";
        egrep = "egrep --color=auto";
        fd    = "find . -type d -name";
        ff    = "find . -type f -name";

      	# --- Git ---
        gi = "git init";
        gic = "git init && git commit --allow-empty -m 'chore: init'";
        gs = "git status";
        gl = "git log --oneline --graph --decorate";
        ga = "git add";
        gaa = "git add --all";
        gc = "git commit -v";
        gca = "git commit -v --amend";
        gco = "git checkout";
        gcm = "git checkout main";
        gp = "git push";
        gd = "git diff";
        gds = "git diff --staged";
        gpl = "git pull";
        gu = "git reset --soft HEAD~1";

        # --- Neovim ---
        v = "nvim";
        sv = "sudo nvim";

        # --- LS Deluxe ---
        l = "lsd -A --group-directories-first";
        ll = "l -lh --header --git";
        lt = "l --tree";
        llt = "ll --tree";

        # --- Miscellaneous ---
        c = "clear";
        ":q" = "exit";

      };

      promptInit = "";

      interactiveShellInit = ''
        # --- functions ---
        function extract() {
          if [ $# -eq 0 ]; then
            echo "Usage: extract <file>"
            return 1
          fi

          local file="$1"

          if [ ! -f "$file" ]; then
            echo -e "ERR: File not found: '$file'"
            return 1
          fi

          case "$file" in
            *.tar.bz2|*.tbz2)   tar xjf "$file";;
            *.tar.gz|*.tgz)     tar xzf "$file";;
            *.tar.xz|*.txz)     tar xJf "$file";;
            *.tar)              tar xf  "$file";;
            *.bz2)              bunzip2 "$file";;
            *.gz)               gunzip  "$file";;
            *.xz)               unxz    "$file";;
            *.zip)              unzip   "$file";;
            *.rar)              unrar x "$file";;
            *.7z)               7z x    "$file";;
            *)
              echo "ERR: Unsupported file type '$file'"
              return 1
              ;;
          esac
        }

        function sp() {
          nvim $(mktemp /tmp/scratchpad.XXXXXX)
        }

        function script() {
          local execute=false
          while getopts ":e" opt; do
            case $opt in
              e) execute=true;;
              *) echo -e "Usage: script [ -e | --execute ]";;
            esac
          done
          local tmpScript=$(mktemp /tmp/script.XXXXXX)
          echo '#!/usr/bin/env bash' > "$tmpScript"
          nvim "$tmpScript"
          if [ $? -eq 0 ]; then
            chmod +x "$tmpScript"
            echo -e "Created executable script at: $tmpScript"
          else
            echo -e "ERR: Neovim exited with errors. File left at $tmpScript"
            return 1
          fi

          if [[ "$execute" == true ]]; then
            echo "Executing: $tmpScript"
            "$tmpScript"
          else
            read -q "?Execute this script now? [y/N] "
            echo
            if [[ $? -eq 0 ]]; then
              echo "Executing: $tmpScript"
              "$tmpScript"
            else
              echo "Run the script manually with: $tmpScript"
            fi
          fi
        }

        function mcd() {
          if [[ $# -eq 0 ]]; then
            echo "Usage: mcd <path/to/dir>"
            return 1
          fi

          local dir="$1"
          mkdir -p -- "$dir"
          cd -- "$dir"
        }

        function oil() {
          if [[ $# -eq 0 ]]; then
            echo "Usage: oil <user>@<host>[:<port>] <remote-path>"
            return 1
          fi

          local userHost=$1
          local remotePath=$2
          local port="22"
          if [[ $userHost =~ :([0-9]+)$ ]]; then
            port="''${match[1]}"
            userHost=''${userHost%%:*}
          fi

          local cmd="oil-ssh://''${userHost}:''${port}/''${remotePath}"
          nvim "$cmd"
        }

        # --- prompt ---
        setopt prompt_subst

        autoload -Uz vcs_info
        zstyle ':vcs_info:*' enable git
        zstyle ':vcs_info:git:*' formats '\e[38;5;6m %b\e[0m %m%u%c %a'
        zstyle ':vcs_info:*' check-for-changes true
        zstyle ':vcs_info:*' stagedstr   '\e[38;5;40m*\e[0m'
        zstyle ':vcs_info:*' unstagedstr '\e[38;5;9m!\e[0m'

        precmd() {
          local lastStatus=$?

          vcs_info

          local promptColor
          if [[ $lastStatus -eq 0 ]]; then
            promptColor=$'\e[38;5;34m'
          else
            promptColor=$'\e[38;5;124m'
          fi

          print -P "%F{97}%~%f ''${vcs_info_msg_0_}"
          PROMPT="%{$promptColor%}%f "
        }
      '';
    };

  };

}
