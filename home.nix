# ===========================================================================
# CONFIGURAÇÃO DO USUÁRIO — Home Manager (APENAS para "rael")
# ===========================================================================
# Este arquivo define TUDO que é do USUÁRIO "rael":
#   - Pacotes instalados APENAS para este usuário
#   - Aliases e config do shell (Fish)
#   - Programas (Git, Htop, Firefox)
#   - Serviços do systemd do usuário (KDE, Polkit)
#   - Configurações de ambiente (GTK, Qt, XDG)
#
# DIFERENÇA CRÍTICA: o que está aqui vale APENAS para o usuário "rael".
# O que está em configuration.nix vale para o SISTEMA INTEIRO.
#
# ARGUMENTOS RECEBIDOS:
#   pkgs     → pacotes do canal PADRÃO (nixos-26.05 — estável)
#   unstable → pacotes do canal UNSTABLE
#   antigos  → pacotes do canal ESTÁVEL ANTERIOR (nixos-25.11)
# ===========================================================================

{ config, pkgs, unstable, antigos, ... }:

let
  extraPkgs = [
    (pkgs.writeShellScriptBin "VirtualBox" ''
      exec ${unstable.virtualboxKvm}/bin/VirtualBox "$@"
    '')
  ];
in
{

  imports = [
    ./gamescope.nix
  ];

  # ===========================================================================
  # IDENTIDADE DO USUÁRIO
  # ===========================================================================
  home.username = "rael";
  home.homeDirectory = "/home/rael";

  # ── STATE VERSION ────────────────────────────────────────────────────────
  # NÃO MEXA. Mantém compatibilidade com a versão atual do Home Manager.
  home.stateVersion = "26.05";

  # ── HOME MANAGER ─────────────────────────────────────────────────────────
  # Ativa o próprio Home Manager (permite usar "hm" e aliases).
  programs.home-manager.enable = true;

  # Silencia aviso de versão: Home Manager 26.11 + Nixpkgs 26.05
  home.enableNixpkgsReleaseCheck = false;

  # ===========================================================================
  # XDG — Configurações de aplicativos padrão
  # ===========================================================================
  xdg = {
    enable = true;
    mime.enable = true;          # Gerencia tipos de arquivo
    mimeApps.enable = true;      # Define apps padrão

    # ── APLICATIVOS PADRÃO ──────────────────────────────────────────────
    # Mude o .desktop abaixo para trocar o navegador padrão.
    # Exemplo: "google-chrome.desktop" ou "firefox.desktop"
    mimeApps.defaultApplications = {
      # --- Navegador ---
      "text/html"                               = "firefox.desktop";
      "x-scheme-handler/http"                   = "firefox.desktop";
      "x-scheme-handler/https"                  = "firefox.desktop";
      "x-scheme-handler/about"                  = "firefox.desktop";
      "x-scheme-handler/unknown"                = "firefox.desktop";

      # --- Gerenciador de Arquivos ---
      "inode/directory"                         = "org.kde.dolphin.desktop";
      "application/x-directory"                 = "org.kde.dolphin.desktop";
      "x-scheme-handler/file"                   = "org.kde.dolphin.desktop";
    };

    # ── MENU DE APLICATIVOS ─────────────────────────────────────────────
    # Cria um arquivo .menu pro sistema saber onde encontrar os apps.
    configFile."menus/applications.menu".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <Menu>
        <Name>Applications</Name>
        <DefaultAppDirs/>
        <DefaultDirectoryDirs/>
      </Menu>
    '';

    # ── ARQUIVOS DE CONFIGURAÇÃO ────────────────────────────────────────
    # Copia arquivos para ~/.config/ no build do Home Manager.
    configFile."noctalia/plugins/controller-battery" = {
      source = ./controller-battery-plugin;
    };
    configFile."noctalia/plugins/nix-manager" = {
      source = ./nix-manager-plugin;
    };
    configFile."noctalia/plugins/hdmi-toggle" = {
      source = ./hdmi-toggle-plugin;
    };
    configFile."fish/conf.d/nixos.fish".source = ./nixos.fish;
    # Notification rules estão definidas em niri-noctalia.nix
  };

  # ===========================================================================
  # PACOTES DO USUÁRIO
  # ===========================================================================
  # Esses pacotes são instalados APENAS para o usuário "rael".
  # A lista está num arquivo separado (packages.nix) para organização.
  home.packages = (import ./packages.nix { inherit pkgs unstable antigos; }) ++ extraPkgs;

  # ===========================================================================
  # GTK — Tema gerenciado pelo nwg-look (NÃO pelo Home Manager)
  # ===========================================================================
  # O nwg-look é uma GUI que aplica temas GTK globalmente. Se configurássemos
  # o tema aqui e no nwg-look, haveria conflito. Por isso deixamos vazio.

  # ===========================================================================
  # Qt — Configurado via qt6ct (sem style.name para não criar conflito)
  # ===========================================================================
  qt = {
    enable = true;
    style.name = null;  # null = deixa o qt6ct gerenciar
  };

  # ===========================================================================
  # PROGRAMAS — Git
  # ===========================================================================
  programs.git = {
    enable = true;
    settings = {
      user.name = "rael";
      user.email = "rael.heck@gmail.com";
    };
  };

  # ===========================================================================
  # FISH SHELL — Aliases e configuração do terminal
  # ===========================================================================
  programs.fish = {
    enable = true;

    # Remove a mensagem de boas-vindas do Fish
    interactiveShellInit = ''
      set fish_greeting

      function noctalia-r
          rm -rf ~/.cache/noctalia-qs/qmlcache
          pkill -f quickshell
          pkill -f noctalia-shell
          sleep 0.5
          nohup noctalia-shell >/dev/null 2>&1 &
          disown
      end
    '';

    # ── ALIASES ─────────────────────────────────────────────────────────
    shellAliases = {
      # ================================================================
      # SISTEMA (NixOS)
      # ================================================================
      sw    = "sudo nixos-rebuild switch --flake ~/home-manager";
      boot  = "sudo nixos-rebuild boot   --flake ~/home-manager";
      try   = "sudo nixos-rebuild test   --flake ~/home-manager";

      # ================================================================
      # ATUALIZAÇÃO
      # ================================================================
      up      = "sudo nixos-rebuild switch --upgrade --flake ~/home-manager";
      update  = "sudo nix flake update --flake ~/home-manager && sudo nixos-rebuild switch --flake ~/home-manager && sudo nix-collect-garbage && sudo nix-env --delete-generations +3 -p /nix/var/nix/profiles/system && sudo nix store optimise";

      # ================================================================
      # HOME MANAGER
      # ================================================================
      hm  = "sudo nixos-rebuild switch --flake ~/home-manager";
      hmu = "sudo nixos-rebuild switch --flake ~/home-manager && nix-collect-garbage && nix-env --delete-generations +3 && nix store optimise";

      # ================================================================
      # LIMPEZA
      # ================================================================
      gc         = "sudo nix-collect-garbage";
      clean      = "sudo nix-collect-garbage && sudo nix-env --delete-generations +3 -p /nix/var/nix/profiles/system";
      user-clean = "nix-collect-garbage && nix-env --delete-generations +3";
      opt        = "sudo nix store optimise";

      # ================================================================
      # NAVEGAÇÃO
      # ================================================================
      flk = "cd ~/home-manager";

      # ================================================================
      # GERENCIAR GERAÇÕES
      # ================================================================
      generations = "sudo nix-env --list-generations -p /nix/var/nix/profiles/system";
      rollback    = "sudo nixos-rebuild switch --rollback --flake /home/rael/home-manager";

      # ================================================================
      # MONITOR HDMI
      # ================================================================
      hdmi-on  = "niri msg output 'HDMI-A-1' on";
      hdmi-off = "niri msg output 'HDMI-A-1' off";
      hdmi-t   = "sh -c \"if niri msg outputs | grep -q 'HDMI-A-1.*disabled'; then niri msg output HDMI-A-1 on; else niri msg output HDMI-A-1 off; fi\"";

      # ================================================================
      # BUSCA
      # ================================================================
      ns = "nix search nixpkgs";
      no = "nixos-option";

      # ================================================================
      # NOCTALIA
      # ================================================================
    };
  };

  # ===========================================================================
  # HTOP — Monitor de processos
  # ===========================================================================
  programs.htop = {
    enable = true;
  };

  # ===========================================================================
  # SERVIÇOS DO SYSTEMD (USUÁRIO) — KDE
  # ===========================================================================
  # Esses serviços rodam no CONTEXTO DO USUÁRIO (não do sistema).
  # São iniciados quando o usuário faz login gráfico.

  # ── kbuildsycoca6 ────────────────────────────────────────────────────────
  # Reconstrói o cache de aplicativos KDE (SyCoCa).
  # Necessário para que novos apps apareçam no menu e no "Abrir com".
  systemd.user.services.kbuildsycoca6 = {
    Unit = {
      Description = "KDE - rebuild SyCoCa (cache de aplicativos)";
      Before = [ "kded.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.kdePackages.kservice}/bin/kbuildsycoca6 --noincremental";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # ── kded ─────────────────────────────────────────────────────────────────
  # Daemon do KDE. Gerencia serviços de inicialização como notificações,
  # atalhos de teclado, montagem automática, etc.
  systemd.user.services.kded = {
    Unit = {
      Description = "KDE Daemon - servicos de inicializacao do KDE";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      Requires = [ "kbuildsycoca6.service" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.kdePackages.kded}/bin/kded6";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # ── Polkit KDE Agent ────────────────────────────────────────────────────
  # (desativado para teste com noctalia shell)
  # systemd.user.services.polkit-kde-authentication-agent-1 = {
  #   Unit = {
  #     Description = "Polkit KDE Authentication Agent";
  #     After = [ "graphical-session.target" ];
  #   };
  #   Service = {
  #     Type = "simple";
  #     ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
  #     Restart = "on-failure";
  #     RestartSec = 1;
  #     TimeoutStopSec = 10;
  #   };
  #   Install = {
  #     WantedBy = [ "graphical-session.target" ];
  #   };
  # };

  # ===========================================================================
  # VARIÁVEIS DE AMBIENTE DO USUÁRIO
  # ===========================================================================
  home.sessionVariables = {
    GTK_THEME = "Adwaita:dark";                 # Tema escuro GTK
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";          # Escala automática Qt
    QT_COLOR_SCHEME = "dark";                   # Modo escuro nativo Qt6
    QT_QPA_PLATFORMTHEME = "qt6ct";             # Tema Qt via qt6ct
    XDG_CURRENT_DESKTOP = "KDE";                # Informa ao sistema que é KDE
  };

  home.sessionPath = [ "$HOME/.local/bin" ];


  # ===========================================================================
  # FIREFOX — Perfil e configurações
  # ===========================================================================
  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      name = "default";
      path = "tjm2xgh3.default";
      isDefault = true;
      settings = {
        # Força tema escuro mesmo em sites que não detectam
        "widget.content.gtk-theme-override" = "Adwaita:dark";
        "ui.systemUsesDarkTheme" = 1;
      };
    };
  };
}
