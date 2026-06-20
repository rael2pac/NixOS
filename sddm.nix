{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    sddm-astronaut
    catppuccin-sddm
    catppuccin-sddm-corners
  ];

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;

    # Tema ativo:
    theme = "sddm-astronaut-theme";

    # ── Temas inclusos ──────────────────────────────────────────
    # Troque o theme acima por um destes nomes:
    #
    #   theme = "elarun";                         # padrão NixOS
    #   theme = "maldives";                       # padrão NixOS
    #   theme = "maya";                           # padrão NixOS
    #   theme = "catppuccin-mocha-mauve";         # catppuccin-sddm
    #   theme = "catppuccin-sddm-corners";        # catppuccin-sddm-corners
    #
    # ── sddm-astronaut-theme ────────────────────────────────────
    # Tema do pacote sddm-astronaut. Precisa de qtmultimedia e
    # qtvirtualkeyboard (já incluídos abaixo).
    # Para desativar, comente as linhas extraPackages abaixo.
    # ────────────────────────────────────────────────────────────

    extraPackages = with pkgs.qt6; [
      qtmultimedia
      qtvirtualkeyboard
    ];
    settings.General.InputMethod = "qtvirtualkeyboard";
  };
}