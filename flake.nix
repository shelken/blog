{
  description = "Development Template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      utils,
      git-hooks,
      ...
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        pre-commit-check = git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            end-of-file-fixer = {
              enable = true;
            };
            trim-trailing-whitespace = {
              enable = true;
            };
            check-merge-conflicts = {
              enable = true;
            };
          };
        };
      in
      {
        checks.pre-commit-check = pre-commit-check;
        devShells.default = pkgs.mkShellNoCC {
          name = "base template";

          packages = with pkgs; [
            hugo
          ];

          shellHook = ''
            ${pre-commit-check.shellHook}
          '';

          # Now we can execute any commands within the virtual environment.
          # This is optional and can be left out to run pip manually.
          postShellHook = ''
            # allow pip to install wheels
          '';
        };
      }
    );
}
