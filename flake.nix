{
  inputs = {
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-trusted-public-keys =
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = { self, nixpkgs, devenv, systems, ... }@inputs:
    let forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in {
      packages = forEachSystem (system: {
        devenv-up = self.devShells.${system}.default.config.procfileScript;
      });

      devShells = forEachSystem (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [{
              # https://devenv.sh/reference/options/
              languages.python = {
                enable = true;
                venv = {
                  enable = true;
                  requirements = ''
                    torchsde
                    einops
                    transformers>=4.28.1
                    tokenizers>=0.13.3
                    sentencepiece
                    safetensors>=0.4.2
                    aiohttp
                    pyyaml
                    Pillow
                    scipy
                    tqdm
                    psutil

                    #non essential dependencies:
                    kornia>=0.7.1
                    spandrel
                    soundfile

                    --extra-index-url https://download.pytorch.org/whl/rocm6.0
                    torch
                    torchvision
                    torchaudio
                  '';
                };
              };
            }];
          };
        });
    };
}
