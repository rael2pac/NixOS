# ===========================================================================
# PACOTES DO USUÁRIO — Lista completa de programas
# ===========================================================================
# Este arquivo é importado pelo home.nix e lista TODOS os pacotes
# instalados para o usuário "rael".
#
# Regras:
#   - pkgs.xxx ou apenas xxx   → canal ESTÁVEL (nixos-26.05)
#   - unstable.xxx             → canal UNSTABLE (nixos-unstable)
#   - antigos.xxx              → canal ESTÁVEL ANTERIOR (nixos-25.11)
#
# Use unstable.xxx quando:
#   1. O pacote não existe na estável (muito novo)
#   2. Você precisa de uma versão mais recente
#
# Use antigos.xxx quando:
#   1. O pacote mais novo quebrou ou tem bug
#   2. Você precisa de uma versão específica antiga
# ===========================================================================

{ pkgs, unstable, antigos, ... }:

with pkgs; [

  # ===========================================================================
  # NAVEGADORES
  # ===========================================================================
  google-chrome              # Google Chrome (navegador principal)

  # ===========================================================================
  # COMUNICAÇÃO
  # ===========================================================================
  vesktop                    # Discord com Vencord (plugins, temas)
  discord                    # Discord oficial (também Electron, usa Wayland via NIXOS_OZONE_WL)
  zapzap                     # WhatsApp Web nativo (eletrônico)
  telegram-desktop           # Telegram messenger
  rustdesk-flutter           # Acesso remoto (alternativa ao AnyDesk)

  # ===========================================================================
  # MÚSICA E VÍDEO
  # ===========================================================================
  spotify                    # Streaming de música
  vlc                        # Reprodutor multimídia versátil
  mpv                        # Reprodutor leve via terminal
  obs-studio                 # Gravação/stream de tela
  obs-studio-plugins.obs-vaapi  # Aceleração VAAPI para OBS (AMD/Intel)
  stremio-linux-shell

  # ===========================================================================
  # DOWNLOAD
  # ===========================================================================
  qbittorrent                # Cliente Torrent
  parabolic                  # Download de áudio/vídeo (yt-dlp com GUI)
  yt-dlp                     # Download de vídeos (YouTube, etc.) via terminal
  video-downloader           # GUI para yt-dlp

  # ===========================================================================
  # ESCRITÓRIO
  # ===========================================================================
  onlyoffice-desktopeditors  # Suíte de escritório (compatível com Office)

  # ===========================================================================
  # SCREENSHOT / ANOTAÇÃO
  # ===========================================================================
  satty                      # Screenshot com anotações (moderno, Wayland)
  swappy                     # Screenshot com edição rápida
  grim                       # Screenshot via terminal (Wayland)
  slurp                      # Seleciona área da tela (usado com grim)

  # ===========================================================================
  # UTILITÁRIOS
  # ===========================================================================
  psmisc                     # Utilitários de processo (killall, pstree, etc.)
  xdg-utils                  # Comandos xdg-open, xdg-mime, etc.
  shared-mime-info           # Banco de tipos MIME
  micro                      # Editor de texto via terminal (moderno)
  nwg-look                   # GUI para aplicar temas GTK
  nwg-displays
  fastfetch                  # Info do sistema (alternativa ao neofetch)
  inxi                       # Info detalhada do hardware
  hardinfo2                  # GUI de info do hardware
  cpu-x                      # Info da CPU (GUI)
  gnome-disk-utility         # Gerenciador de discos (GNOME Disks)
  gnome-calculator           # Calculadora oficial
  loupe                      # Visualizador de imagens moderno
  evince                     # Visualizador de PDFs (ou gnome-papers se disponível)
  nautilus                   # Gerenciador de arquivos (com suporte à Barra de Espaço) 
  distrobox                  # Contêineres estilo Ubuntu/Debian/Arch
  podman-tui                 # Interface TUI para Podman
  #gearlever                  # Gerenciador de contêineres (GUI)
  appimage-run               # Roda AppImages sem instalar
  dwarfs                     # Sistema de arquivos compactado (usado por AppImage)
  bchunk                     # Converte .bin/.cue para .iso
  unstable.mame-tools        # Inclui chdman (.bin/.cue → .chd preserva áudio)
  wl-clipboard               # Área de transferência via terminal (Wayland)
  waydroid-helper            # Scripts auxiliares para Waydroid
  rclone-browser             # GUI para Rclone
  distrobox-tui              # TUI para gerenciar contêineres Distrobox
  distroshelf                # Gerenciador de contêineres (GUI)
  rclone                     # Sincronização com nuvem (Google Drive, Mega, etc.)
  rclone-ui                  # Interface web para Rclone
  rclone-browser             # GUI adicional para Rclone
  nitch
  flatpak
  gnome-software              # Loja de aplicativos (gerencia Flatpaks)
  gemini-cli
  boxbuddy
  cava
  
  # ===========================================================================
  # COMPACTAÇÃO
  # ===========================================================================
  kdePackages.ark            # KDE Ark (extrair/compactar arquivos)
  unrar                      # Extrair .rar
  unzip                      # Extrair .zip
  zip                        # Criar .zip
  peazip                     # GUI avançada para compactação
  p7zip                      # 7zip via terminal
  lz4                        # Compactação rápida LZ4
  zstd                       # Compactação Zstandard (alta taxa)

  # ===========================================================================
  # TEMA GTK
  # ===========================================================================
  adw-gtk3                   # Tema Adwaita para GTK3 (moderno, escuro)

  # ===========================================================================
  # TEMA QT (via qt5ct + qt6ct)
  # ===========================================================================
  libsForQt5.qt5ct                    # Configurador de tema Qt5
  qt6Packages.qt6ct                   # Configurador de tema Qt6
  qt6.qtwayland                       # Suporte Qt6 ao Wayland
  kdePackages.breeze                  # Tema Breeze (KDE)
  kdePackages.breeze-icons            # Ícones Breeze
  

  # ===========================================================================
  # KDE TOOLS
  # ===========================================================================
  kdePackages.kservice       # Serviços KDE (kbuildsycoca6, etc.)
  kdePackages.dolphin        # Gerenciador de arquivos KDE
  kdePackages.konsole        # Terminal KDE (necessário para service menus)
  kdePackages.kio            # KDE IO (acesso a rede, arquivos, etc.)
  kdePackages.kio-extras     # Extras do KIO (SMB, SFTP, etc.)
  kdePackages.filelight      # Analisador de espaço em disco
  kdePackages.dolphin-plugins # Plugins para o Dolphin
  kdePackages.kdialog        # Diálogos GUI via terminal
  kdePackages.kde-cli-tools  # Ferramentas CLI do KDE
  kdePackages.plasma-integration # Integração Plasma (notificações, etc.)

  # ===========================================================================
  # JOGOS
  # ===========================================================================
  lutris                     # Gerenciador de jogos (Wine, native, emuladores)
  #unstable.hydralauncher     # Lançador de jogos (alternativa ao Steam)
  winetricks                 # Instala dependências do Wine (vcrun, dotnet)
  wine-staging               # Wine atualizado (com patches extras)
  protonplus                 # Gerenciador de versões do Proton (Steam)
  protonup-qt                # GUI para gerenciar Proton-GE
  gamescope                  # Micro-compositor para jogos (reduz input lag)
  gamescope-wsi
  lsfg-vk                    # Lossless Scaling Frame Generation (Vulkan)
  lsfg-vk-ui                 # Interface para o Lossless Scaling
  # ===========================================================================
  # DESENVOLVIMENTO
  # ===========================================================================
  nil                        # LSP para Nix (autocomplete, diagnóstico)
  vscode                     # VS Code (editor de código)
  vscode-extensions.kamadorueda.alejandra # Formatter Nix para VS Code
  zed-editor                 # Zed (editor de código moderno, rápido)

  # ===========================================================================
  # PACOTES DO UNSTABLE (não disponíveis ou desatualizados na estável)
  # ===========================================================================
  # Estes pacotes são baixados do canal nixos-unstable porque:
  #   - Não existem na versão estável OU
  #   - Precisam da versão mais recente para funcionar corretamente
  # ===========================================================================
  unstable.motrix-next    # Gerenciador de downloads (multi-protocolo)
  unstable.bottles        # Gerenciador de Wine com prefixos isolados
  unstable.heroic         # Launcher da Epic Games/GOG
  unstable.mangohud       # Overlay de performance (versão mais recente)
  unstable.goverlay       # GUI para configurar o MangoHud
  unstable.opencode                   # Assistente de código via terminal
  unstable.ryubing
  unstable.eden
  unstable.nsz              #Usada para converter roms do nintendo switch
  unstable.pcsx2
  ]
