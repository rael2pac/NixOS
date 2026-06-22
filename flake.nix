{
  # ===========================================================================
  # DESCRIÇÃO
  # ===========================================================================
  # Este arquivo é o ponto de entrada do Flake NixOS.
  # Ele declara as DEPENDÊNCIAS EXTERNAS (inputs) e como elas são
  # combinadas para construir o SISTEMA (outputs).
  #
  # Analogia: é como se fosse um package.json do NixOS — define de onde
  # baixar os pacotes e como montar a configuração final do sistema.
  # ===========================================================================
  description = "NixOS com Niri (Wayland) + Home Manager + Noctalia";

  # ===========================================================================
  # INPUTS — Fontes externas de pacotes e configurações
  # ===========================================================================
  # Cada input é um repositório Git que o Nix baixa e fixa no
  # flake.lock (igual um package-lock.json). Assim o build é
  # REPRODUTÍVEL: todo mundo que rodar esse flake.lock terá os
  # mesmos commits exatos de cada input.
  # ===========================================================================
  inputs = {
    # ── CANAL ESTÁVEL (PADRÃO) ─────────────────────────────────────────────
    # Canais estáveis do NixOS são lançados a cada 6 meses (25.05, 25.11, 26.05).
    # Eles só recebem BACKPORTS de segurança e correções, então os pacotes
    # são mais testados e estáveis.
    #
    # USEI nixos-26.05 porque: lançado em Maio/2026, tem os pacotes mais
    # recentes DENTRO de um ciclo estável. Perfeito para um sistema que
    # precisa funcionar sem surpresas.
    #
    # TROCAR DE CANAL: se quiser voltar ao unstable, mude abaixo para
    # "nixos-unstable". Se quiser uma estável mais antiga, use "nixos-25.11".
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    # ── CANAL UNSTABLE (PACOTES NOVOS) ────────────────────────────────────
    # O canal unstable tem os pacotes MAIS RECENTES do NixOS.
    # Use ele apenas para pacotes individuais (via unstable.xxx) — NUNCA
    # para o sistema inteiro, pois pode quebrar a cada atualização.
    #
    # Referencie como "unstable" no código (ex: unstable.virtualbox).
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # ── CANAL ESTÁVEL ANTERIOR (PACOTES MAIS VELHOS) ──────────────────────
    # Útil se algum programa só funciona numa versão específica antiga.
    # Referencie como "antigos" no código (ex: antigos.firefox).
    nixpkgs-stable-old.url = "github:nixos/nixpkgs/nixos-25.11";

    # ── HOME MANAGER ──────────────────────────────────────────────────────
    # Gerencia PACOTES e CONFIGURAÇÕES do USUÁRIO (~/home.nix).
    # Diferente da config do sistema (configuration.nix), que é global.
    #
    # "follows nixpkgs" = usa a MESMA VERSÃO do nixpkgs do sistema,
    # garantindo compatibilidade total.
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ── NOCTALIA ──────────────────────────────────────────────────────────
    # Runtime/Browser/Launcher focado em privacidade e organização.
    # Usa v4.7.7 (versão específica, não segue canal).
    noctalia = {
      url = "github:noctalia-dev/noctalia/v4.7.7";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ── NIRIMOD ───────────────────────────────────────────────────────────
    # Gerenciador de configuração do Niri (compositor Wayland).
    # Aplica themes, keybinds e layouts no Niri automaticamente.
    nirimod = {
      url = "github:srinivasr/nirimod";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # ===========================================================================
  # OUTPUTS — O que este Flake CONSTRÓI
  # ===========================================================================
  # Aqui declaramos como os inputs se combinam para gerar:
  #   - nixosConfigurations.nixos → a configuração final do sistema NixOS
  # ===========================================================================
  outputs = { self, nixpkgs, nixpkgs-unstable, nixpkgs-stable-old, home-manager, noctalia, nirimod, ... }@inputs:
  let
    system = "x86_64-linux";

    # ── ALIASES PARA ACESSO RÁPIDO ───────────────────────────────────────
    # Em vez de digitar "nixpkgs-unstable.legacyPackages.x86_64-linux.firefox"
    # toda vez, criamos atalhos:
    #
    # unstable  → acesso rápido ao canal unstable (pacotes mais novos)
    # antigos   → acesso rápido ao canal estável anterior (pacotes mais velhos)
    unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    antigos  = import nixpkgs-stable-old {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    # ── CONFIGURAÇÃO DO SISTEMA ──────────────────────────────────────────
    # O nome "nixos" é o HOSTNAME que você definiu em configuration.nix
    # (networking.hostName). Para rebuildar:
    #   sudo nixos-rebuild switch --flake ~/home-manager#nixos
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        inherit system;

        # Passa os inputs e aliases como argumentos especiais para TODOS
        # os módulos NixOS. Isso permite usar "unstable", "antigos",
        # "inputs" dentro de qualquer .nix sem precisar importar de novo.
        specialArgs = { inherit inputs unstable antigos; };

        # ── MÓDULOS QUE FORMAM O SISTEMA ────────────────────────────────
        modules = [
          # --- Hardware (gerado pelo nixos-generate-config) ---
          # Detecta automático: discos, CPU, kernel modules, etc.
          ./hardware-configuration.nix

          # --- Config principal do sistema (global) ---
          # Aqui vai: rede, áudio, vídeo, segurança, serviços, etc.
          ./configuration.nix

          # --- Home Manager integrado ao NixOS ---
          # Com isso, "sudo nixos-rebuild switch" já aplica TANTO
          # as configs de sistema QUANTO as do usuário.
          home-manager.nixosModules.home-manager
          {
            # Usa os pacotes do sistema (evita duplicar no /nix/store)
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            # Se um arquivo de config já existir, faz backup com .backup
            home-manager.backupFileExtension = "backup";

            # Passa argumentos extras pro Home Manager (unstable, antigos...)
            home-manager.extraSpecialArgs = { inherit unstable antigos noctalia nirimod inputs; };

            # Importa os módulos de usuário (HOME config)
            home-manager.users.rael = {
              imports = [
                ./home.nix              # Config principal do usuário
                ./niri-noctalia.nix     # Niri compositor + Noctalia
                ./controller-battery-hm.nix  # Bateria de controles
              ];
            };
          }
        ];
      };
    };
  };
}
