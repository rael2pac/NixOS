# ===========================================================================
# MÓDULO: NIRI + NOCTALIA (Home Manager)
# ===========================================================================
# Configura o compositor Wayland Niri, o Noctalia (runtime focado em
# privacidade) e o NiriMod (gerenciador de config do Niri).
#
# Fluxo:
#   Niri é o compositor Wayland (gerencia janelas)
#   Noctalia é o ambiente/launcher que roda SOBRE o Niri
#   NiriMod gerencia a config do Niri (~/.config/niri/config.kdl)
# ===========================================================================
{ pkgs, noctalia, nirimod, ... }:

let
  noctaliaPackage = noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  # ── PACOTES INSTALADOS ─────────────────────────────────────────────────
  home.packages = with pkgs; [
    niri                               # Compositor Wayland (scrollável)
    kitty                              # Terminal padrão do Niri
    noctaliaPackage                    # Noctalia (runtime/launcher)
    nirimod.packages.${pkgs.stdenv.hostPlatform.system}.default  # NiriMod
  ];

  # ── CONFIG DO NIRI ─────────────────────────────────────────────────────
  # Gerenciada pelo NiriMod diretamente em ~/.config/niri/config.kdl
  # Não editamos aqui porque o NiriMod sobrescreve o arquivo.

  # ── REGRAS DE NOTIFICAÇÃO ──────────────────────────────────────────────
  # Bloqueia notificações de Screenshot (evita spam)
  xdg.configFile."noctalia/notification-rules.json".source = ./notification-rules.json;
}
