{
  description = "Shell script for burn-in and testing of new or re-purposed drives";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    script = (pkgs.writeScriptBin "disk-burnin.sh" (builtins.readFile ./disk-burnin.sh)).overrideAttrs (old: {
      buildCommand = "${old.buildCommand}\n patchShebangs $out";
    });
    deps = [pkgs.e2fsprogs pkgs.smartmontools];
  in {
    formatter.${system} = pkgs.alejandra;

    packages.${system}.default = pkgs.symlinkJoin {
      name = "disk-burnin.sh";
      paths = [script] ++ deps;
      buildInputs = [pkgs.makeWrapper];
      postBuild = "wrapProgram $out/bin/disk-burnin.sh --prefix PATH : $out/bin";
    };

    devShells.${system}.default = pkgs.mkShell {
      buildInputs =
        [
          pkgs.shellcheck
        ]
        ++ deps;
    };
  };
}
