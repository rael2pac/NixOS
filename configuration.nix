# ===========================================================================
# CONFIGURAÇÃO PRINCIPAL DO SISTEMA — NixOS (GLOBAL)
# ===========================================================================
# Este arquivo define TUDO que é GLOBAL no sistema:
#   - Boot, kernel, hardware
#   - Rede, firewall, localização
#   - Serviços (áudio, vídeo, impressão, bluetooth)
#   - Pacotes instalados para TODOS os usuários
#   - Virtualização (VirtualBox, Podman, Waydroid)
#   - Steam, jogos, otimizações
#
# DIFERENÇA CRÍTICA: o que está aqui vale para o SISTEMA INTEIRO.
# O que está em home.nix vale APENAS para o usuário "rael".
#
# ARGUMENTOS RECEBIDOS:
#   pkgs      → pacotes do canal PADRÃO (nixos-26.05 — estável)
#   unstable  → pacotes do canal UNSTABLE (via flake.nix)
#   antigos   → pacotes do canal ESTÁVEL ANTERIOR (nixos-25.11)
#   inputs    → todos os inputs do flake (para nixPath, registry, etc.)
# ===========================================================================

{ config, pkgs, lib, unstable, antigos, inputs, ... }:

{
  # ===========================================================================
  # IMPORTS — Sub-arquivos de configuração
  # ===========================================================================
  # Cada arquivo aqui é um "módulo NixOS" separado. Isso mantém a config
  # organizada em vez de um monólito gigante.
  imports =
      [
        ./hardware-configuration.nix   # Detecção automática de hardware
        ./disks-config.nix             # Montagem dos discos /mnt/1T e /mnt/4T
        ./sddm.nix                     # Gerenciador de login (SDDM com Wayland)
        ./power.nix                    # Gerenciamento de energia (suspensão)
        ./rclone-services.nix          # Serviços Rclone (Gdrive, Mega, OneDrive)
        ./controller-battery.nix       # Regras udev para bateria de controles
      ];

  # Ativa o módulo de bateria de controles (definido no controller-battery.nix)
  controller-battery.enable = true;

  # ===========================================================================
  # VARIÁVEL GLOBAL — Nome do usuário
  # ===========================================================================
  # Define "nomeUsuario" como argumento disponível em TODOS os submódulos.
  # Útil para não ter que digitar "rael" manualmente em vários lugares.
  _module.args.nomeUsuario = "rael";

  # ===========================================================================
  # BOOT — Inicialização do sistema
  # ===========================================================================
  boot.loader.systemd-boot.enable = true;          # systemd-boot (rápido, simples)
  boot.loader.efi.canTouchEfiVariables = true;     # Permite configurar EFI

  # ── KERNEL ────────────────────────────────────────────────────────────────
  # ESCOLHA DO KERNEL: descomente APENAS UMA das opções abaixo.
  # As outras devem ficar comentadas para evitar conflito.
  #
  # RAMO 1 — Kernel LTS estável  (padrão, mais testado)
  # boot.kernelPackages = pkgs.linuxPackages;
  #
  # RAMO 2 — Kernel mais recente do canal estável
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  #
  # RAMO 3 — Kernel LTS do unstable (pacotes mais novos)
  # boot.kernelPackages = unstable.linuxPackages;
  #
  # ATIVO — Kernel mais recente do unstable (o mais novo de todos)
  boot.kernelPackages = unstable.linuxPackages_latest;

  # ── MÓDULOS DO KERNEL ────────────────────────────────────────────────────
  #          +------------------------------------------+
  #          |  KVM = comentado  |  Clássico = ativo    |
  #          +------------------------------------------+
  boot.kernelModules = [
    # "vboxdrv"        # ← descomente se for usar VirtualBox CLÁSSICO
    # "vboxnetadp"     # ← descomente se for usar VirtualBox CLÁSSICO
    # "vboxnetflt"     # ← descomente se for usar VirtualBox CLÁSSICO
    "fuse"
    "amdgpu"
    "br_netfilter"
    "tun"
  ];

  # ── SYSCTL (Parâmetros do Kernel) ────────────────────────────────────────
  # net.ipv4.ip_forward = 1 → Permite roteamento de pacotes.
  # Necessário para o Waydroid se comunicar com a rede.
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  # ===========================================================================
  # UDEV — Regras de dispositivos
  # ===========================================================================
  #          +------------------------------------------+
  #          |  KVM = vazio        |  Clássico = ativo  |
  #          +------------------------------------------+
  services.udev.extraRules = ''
    # Permite ao usuário rael gerenciar clocks da GPU (necessário para GameMode)
    SUBSYSTEM=="drm", KERNEL=="card1", RUN+="${pkgs.coreutils}/bin/chmod 0666 /sys/class/drm/card1/device/power_dpm_force_performance_level"
    # KERNEL=="vboxdrv", GROUP="vboxusers", MODE="0660"    # ← descomente p/ CLÁSSICO
    # KERNEL=="vboxnetctl", GROUP="vboxusers", MODE="0660" # ← descomente p/ CLÁSSICO
  '';

  # ===========================================================================
  # REDE — Hostname, NetworkManager, Firewall
  # ===========================================================================
  networking.hostName = "nixos";                          # Nome do PC na rede
  networking.networkmanager.enable = true;                # Gerencia WiFi/Rede

  # ── FIREWALL ─────────────────────────────────────────────────────────────
  # trustedInterfaces → não bloqueia nada na interface waydroid0
  # checkReversePath  → false para não descartar pacotes do Waydroid
  networking.firewall.trustedInterfaces = [ "waydroid0" ];
  networking.firewall.checkReversePath = false;

  # Rustdesk — portas necessárias para acesso remoto
  networking.firewall.allowedTCPPorts = [ 21115 21116 21117 21118 21119 ];
  networking.firewall.allowedUDPPorts = [ 21116 ];

  # ===========================================================================
  # LOCALIZAÇÃO — Timezone, Idioma, Teclado
  # ===========================================================================
  time.timeZone = "America/Sao_Paulo";                   # Fuso horário BR
  i18n.defaultLocale = "pt_BR.UTF-8";                    # Idioma padrão

  # ── LOCAIS EXTRAS ────────────────────────────────────────────────────────
  # Define o formato regional brasileiro para data, moeda, papel, etc.
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # ── TECLADO ──────────────────────────────────────────────────────────────
  services.xserver.xkb = {
    layout = "br";                                       # ABNT2
    variant = "";
  };
  console.keyMap = "br-abnt2";                           # Teclado no terminal

  # ===========================================================================
  # INTERFACE GRÁFICA — Niri (Wayland) + XWayland
  # ===========================================================================
  services.xserver.enable = true;      # Habilita X11 (necessário pro XWayland)
  programs.xwayland.enable = true;     # Roda apps X11 dentro do Wayland

  programs.niri.enable = true;         # Niri — compositor Wayland (scrollável)

  # ── POLKIT ────────────────────────────────────────────────────────────────
  # Gerencia permissões (montar discos, autorizar ações de sistema).
  security.polkit.enable = true;

  # ── DCONF ─────────────────────────────────────────────────────────────────
  # Banco de configurações do GNOME/GTK. Necessário pro GVFS.
  programs.dconf.enable = true;

  # ── UDISKS2 + GVFS ───────────────────────────────────────────────────────
  # udisks2 → montar/desmontar discos pelo gerenciador de arquivos
  # gvfs     → "lixeira", montar pendrives automaticamente, etc.
  services.udisks2.enable = true;
  services.gvfs.enable = true;

  # ── PORTAL XDG ───────────────────────────────────────────────────────────
  # Permite que apps Flatpak/nativos peçam permissões (tela, arquivos...).
  # Necessário para captura de tela no Wayland.
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      kdePackages.xdg-desktop-portal-kde
    ];
    config = {
      common = {
        default = "gtk";
      };
      "kde" = {
        default = "kde";
      };
    };
  };

  # ── IMPRESSÃO ────────────────────────────────────────────────────────────
  services.printing.enable = true;

  # ── FLATPAK ──────────────────────────────────────────────────────────────
  services.flatpak.enable = true;

  # ── APPIMAGE ─────────────────────────────────────────────────────────────
  # Permite rodar .AppImage diretamente (sem extrair).
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # ===========================================================================
  # ÁUDIO — PipeWire (substituto do PulseAudio)
  # ===========================================================================
  services.pulseaudio.enable = false;      # Desativa PulseAudio (usamos PipeWire)
  security.rtkit.enable = true;            # Prioridade de áudio em tempo real
  services.pipewire = {
    enable = true;                         # PipeWire: áudio + vídeo moderno
    alsa.enable = true;                    # Suporte a apps ALSA
    alsa.support32Bit = true;              # Apps 32 bits (Steam, Wine)
    pulse.enable = true;                   # Compatibilidade com PulseAudio
  };

  # ===========================================================================
  # BLUETOOTH
  # ===========================================================================
  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";  # Perfis de áudio e periféricos
      Experimental = true;                  # Ativa codecs novos (LDAC, etc.)
    };
  };
  services.blueman.enable = true;           # Interface gráfica do Bluetooth

  # ===========================================================================
  # VIRTUALBOX — SELETOR KVM vs CLÁSSICO
  # ===========================================================================
  #          +------------------------------------------+
  #          |  MODO KVM (ATIVO)  |  MODO CLÁSSICO      |
  #          +------------------------------------------+
  #          |  package = vboxKvm |  package = vbox      |
  #          |  Sem módulos       |  Precisa de vboxdrv  |
  #          |  Kernel novo OK    |  Kernel específico   |
  #          +------------------------------------------+
  #
  # ── COMO TROCAR (KVM → CLÁSSICO) ──────────────────────────────────────
  #   1. Aqui:     comente as 4 linhas ATIVO e descomente as 4 CLÁSSICO
  #   2. Kernel:   descomente "vboxdrv", "vboxnetadp", "vboxnetflt"
  #   3. Udev:     descomente as regras vboxdrv/vboxnetctl
  #   4. Usuário:  descomente "vboxusers", comente "kvm"
  #   5. Rebuild
  #
  # ── CLÁSSICO (com módulos do kernel) ──────────────────────────────────
  # Descomente estas 6 linhas QUANDO o kernel suportar vboxdrv de novo:
  # virtualisation.virtualbox.host.enable = true;
  # virtualisation.virtualbox.host.enableKvm = false;
  # virtualisation.virtualbox.host.addNetworkInterface = true;
  # virtualisation.virtualbox.host.package = unstable.virtualbox;
  # virtualisation.virtualbox.host.enableHardening = false;
  # virtualisation.virtualbox.host.enableExtensionPack = false;
  #
  # ── KVM (ATIVO — sem módulos, qualquer kernel) ───────────────────────
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableKvm = true;
  virtualisation.virtualbox.host.addNetworkInterface = false;
  virtualisation.virtualbox.host.package = unstable.virtualboxKvm;
  virtualisation.virtualbox.host.enableHardening = false;
  virtualisation.virtualbox.host.enableExtensionPack = false;

  # ===========================================================================
  # USUÁRIOS
  # ===========================================================================
  users.users.rael = {
    isNormalUser = true;
    description = "rael";
    extraGroups = [
      "networkmanager"  # Pode configurar rede
      "wheel"           # Pode usar sudo
      "kvm"             # ← comente p/ CLÁSSICO, ative p/ KVM
      # "vboxusers"     # ← descomente p/ CLÁSSICO, comente p/ KVM
      "storage"         # Pode montar discos
    ];
    shell = pkgs.fish;                      # Shell padrão: Fish
    packages = with pkgs; [
      kdePackages.kate                      # Editor de texto KDE
    ];
  };

  # ── NAVEGADOR ────────────────────────────────────────────────────────────
  programs.firefox.enable = true;

  # ── SHELL (FISH) ─────────────────────────────────────────────────────────
  programs.fish.enable = true;
  environment.shells = with pkgs; [ fish ];

  # ===========================================================================
  # SEGURANÇA E PERMISSÕES
  # ===========================================================================
  # ── PACOTES NÃO-LIVRES (UNFREE) ─────────────────────────────────────────
  # Permite instalar Chrome, Steam, Spotify, etc.
  nixpkgs.config.allowUnfree = true;

  # ── PACOTES INSEGUROS PERMITIDOS ────────────────────────────────────────
  # Ventoy tem vulnerabilidade conhecida, mas precisamos dele.
  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-gtk3-1.1.12"
  ];

  # ── VARIÁVEIS DE AMBIENTE ───────────────────────────────────────────────
  # NIXPKGS_ALLOW_UNFREE = 1 → força permissão unfree mesmo em modo flakes
  environment.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_ENABLE_HIGHDPI_SCALING = "1";
    XDG_CURRENT_DESKTOP = "KDE";
    # Obriga Electron apps (Discord, Vesktop, Chrome, etc.) a usar Wayland
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  # ===========================================================================
  # PACOTES GLOBAIS DO SISTEMA
  # ===========================================================================
  # Instalados para TODOS os usuários. Prefira colocar pacotes em home.nix
  # (via home.packages) para não poluir o sistema global.
  environment.systemPackages = with pkgs; [
    wget
    xwayland-satellite              # XWayland otimizado
    gsettings-desktop-schemas       # Schemas GNOME (necessário pro portal ler cor escura)
  ];

  # ===========================================================================
  # FONTES
  # ===========================================================================
  fonts.packages = with pkgs; [
    nerd-fonts.meslo-lg          # Fonte para terminal (ícones)
    nerd-fonts.jetbrains-mono    # Fonte para código (ícones)
    nerd-fonts.fira-code         # Fonte para código (ícones)
    corefonts                    # Fontes Microsoft (Arial, Times, etc.)
    vista-fonts                  # Fontes Microsoft Vista
  ];

  # ===========================================================================
  # PLACA DE VÍDEO — AMD
  # ===========================================================================
  hardware.graphics = {
    enable = true;               # Aceleração gráfica
    enable32Bit = true;          # Suporte 32 bits (Steam, Wine)
  };

  boot.initrd.kernelModules = [ "amdgpu" ];       # AMD GPU no initrd
  services.xserver.videoDrivers = [ "amdgpu" ];   # Driver AMD

  # ===========================================================================
  # JOGOS — Steam, GameMode, ZRAM
  # ===========================================================================
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;          # Steam Remote Play
    dedicatedServer.openFirewall = true;     # Servidor dedicado Steam
    gamescopeSession.enable = true;          # Sessão gamescope para jogos
  };

  programs.gamemode.enable = true;
  programs.gamemode.settings = {
    general = {
      softrealtime = "auto";
      renice = -10; # Prioridade ALTA (negativo é melhor no Linux)
    };
    gpu = {
      apply_gpu_optimisations = "accept-all";
      gpu_device = 1; # Sua RX 6600
      amd_performance_level = "high";
    };
    custom = {
      start = "echo high > /sys/class/drm/card1/device/power_dpm_force_performance_level";
      end = "echo auto > /sys/class/drm/card1/device/power_dpm_force_performance_level";
    };
  };
  zramSwap.enable = true;                     # Swap na RAM (comprimido)

  # ===========================================================================
  # MANUTENÇÃO — Limpeza automática do /nix/store
  # ===========================================================================
  # ── COLETOR DE LIXO DIÁRIO ──────────────────────────────────────────────
  # Remove pacotes não referenciados com mais de 14 dias.
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 14d";
  };

  # ── LIMPEZA DE GERAÇÕES ─────────────────────────────────────────────────
  # Mantém apenas as 2 últimas gerações do sistema (atual + rollback).
  systemd.services.nix-gc-custom = {
    description = "Limpeza customizada para manter apenas 3 geracoes do NixOS";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.nix}/bin/nix-env --delete-generations +3 -p /nix/var/nix/profiles/system";
    };
    wantedBy = [ "multi-user.target" ];
    startAt = "daily";
  };

  # Otimiza o store (reduz espaço com hardlinks)
  nix.settings.auto-optimise-store = true;

  # ===========================================================================
  # VIRTUALIZAÇÃO — Podman + Waydroid
  # ===========================================================================
  # ── PODMAN ───────────────────────────────────────────────────────────────
  # Alternativa ao Docker. dockerCompat = true faz o Podman aceitar
  # comandos "docker" como alias.
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # ── WAYDROID ─────────────────────────────────────────────────────────────
  # Roda Android (Android 11) dentro do Linux via contêiner.
  virtualisation.waydroid.enable = true;
  virtualisation.waydroid.package = pkgs.waydroid;

  # ── FUSE ─────────────────────────────────────────────────────────────────
  # Permite que usuários montem sistemas de arquivos FUSE (Rclone, etc.)
  programs.fuse.userAllowOther = true;

  # ── FWUPD ────────────────────────────────────────────────────────────────
  services.fwupd.enable = false;     # Desativado (não atualizamos firmware)

  # ===========================================================================
  # NIX — Configurações do próprio gerenciador de pacotes
  # ===========================================================================
  # command-not-found   → desativado (usamos nix-index, que é mais rápido)
  programs.command-not-found.enable = false;

  programs.nix-index = {
    enable = true;                    # Indexa pacotes para busca rápida
    enableFishIntegration = true;     # Sugere pacotes no Fish
  };

  # ── NIX PATH ─────────────────────────────────────────────────────────────
  # Permite usar "nix-shell -p <pacote>" sem configurar canais manuais.
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  # ── REGISTRY ─────────────────────────────────────────────────────────────
  # Permite "nix shell nixpkgs#firefox" usando a MESMA versão do sistema.
  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  # ── EXPERIMENTAL FEATURES ────────────────────────────────────────────────
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.warn-dirty = false;    # Não avisa se o flake estiver sujo

  # ── STATE VERSION ────────────────────────────────────────────────────────
  # NÃO MEXA. Isso diz ao NixOS: "aplicas as regras de compatibilidade
  # da versão 26.05". Se você mudar, pode quebrar configurações existentes.
  system.stateVersion = "26.05";
}
