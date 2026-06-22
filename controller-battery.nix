# ===========================================================================
# MÓDULO: BATERIA DE CONTROLES (Sistema Global)
# ===========================================================================
# Este módulo NixOS adiciona OPÇÕES à configuração do sistema.
# Quando ativado (controller-battery.enable = true), ele:
#   1. Ativa o driver xpadneo (controles Xbox via Bluetooth)
#   2. Cria regras udev para detectar bateria de controles
#   3. Instala libnotify (biblioteca de notificações)
#
# A NOTIFICAÇÃO em si é feita pelo MÓDULO DO HOME MANAGER
# (controller-battery-hm.nix), que escuta os eventos do udev
# e envia a notificação para o usuário.
# ===========================================================================
{ config, pkgs, lib, ... }:

{
  # ── OPÇÃO: controller-battery.enable ───────────────────────────────────
  options.controller-battery = {
    enable = lib.mkEnableOption "Monitoramento de bateria de controles via notificação";
  };

  # ── CONFIGURAÇÃO (ativada quando enable = true) ────────────────────────
  config = lib.mkIf config.controller-battery.enable {
    # Driver para controles Xbox via Bluetooth/adaptador
    hardware.xpadneo.enable = true;

    # libnotify → permite enviar notificações via notify-send
    environment.systemPackages = with pkgs; [
      libnotify
    ];

    # ── REGRAS UDEV ────────────────────────────────────────────────────
    # Quando um controle conecta (via Bluetooth ou xpadneo), o udev
    # aciona um serviço systemd que chama o script de notificação.
    services.udev.extraRules = ''
      SUBSYSTEM=="power_supply", KERNEL=="ps-controller-battery-*", ACTION=="add", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}+="controller-battery-notify@$kernel.service"
      SUBSYSTEM=="power_supply", KERNEL=="xpadneo-*", ACTION=="add", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}+="controller-battery-notify@$kernel.service"
    '';
  };
}
