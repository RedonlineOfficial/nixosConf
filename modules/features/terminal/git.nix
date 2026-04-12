{ self, inputs, ... }: {

  flake.nixosModules.git = { pkgs, ... }: {

    programs.git = {
      enable = true;

      config = {
        init.defaultBranch = "main";
        core.editor = "nvim -f";
        user = {
          name = "RedonlineOfficial";
          email = "dev@redonline.me";
        };
        pull.rebase = false;
        commit.template = "${pkgs.writeText "git-commit-template" ''
          ##### ================== Conventional Commit Template ==================
          ### <type>(<scope>)!: <description>
          ### ------------- MAX 50 CHARACTERS -------------|


          ### <body>
          ### ------------------------ MAX 72 CHARACTERS ------------------------|


          ### <footer>
          ### ------------------------ MAX 72 CHARACTERS ------------------------|
          ##### ========================== END TEMPLATE ==========================

          # <type>:
          #   - feat:     add, change, or remove features
          #   - fix:      bug fixes
          #   - chore:    routine tasks
          #   - docs:     changes to documentation
          #   - style:    changes that don't affect code logic
          #   - refactor: changes that restructure the code without changing logic
          #   - test:     adding or updating tests
          #   - build:    changes to build related components
          #   - perf:     changes to code performance
          #
          # <scope>:
          #   - optional
          #   - scopes vary by project
          #   - do not use issue identifiers
          #
          # !:
          #   - breaking change indicator
          #   - breaking changes shall be described in <footer>
          #
          # <description>:
          #   - mandatory
          #   - concise description of change written in imperative present tense
          #   - do not use capitalization or punctuation
          #
          # <body>:
          #   - optional
          #   - expands upon description to include motivation, details, etc
          #   - written in imperative present tense
          #
          # <footer>:
          #   - optional
          #   - contains issue references and information about breaking changes
          #   - can reference issue identifiers
          #
          # versioning (MAJOR.MINOR.PATCH)
          #   - breaking changes increment MAJOR
          #   - feat or fix increments MINOR
          #   - all other changes increments PATCH
        ''}";
      };
    };

  };

}
