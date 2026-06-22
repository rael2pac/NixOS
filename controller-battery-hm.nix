# ===========================================================================
# MÓDULO: NOTIFICAÇÃO DE BATERIA DE CONTROLES (Home Manager)
# ===========================================================================
# Este módulo roda no CONTEXTO DO USUÁRIO. Ele cria:
#   1. Um SCRIPT (controller-battery-notify) que lê o nível da bateria
#      do controle e envia uma notificação via notify-send
#   2. Um SERVIÇO SYSTEMD (controller-battery-notify@) que é ativado
#      pelas regras udev definidas em controller-battery.nix
#
# Funcionamento:
#   Controle conecta → udev detecta → systemd ativa o serviço →
#   script lê /sys/class/power_supply/... → notify-send mostra %
# ===========================================================================
{ pkgs, ... }:

let
  # ── SCRIPT DE NOTIFICAÇÃO ─────────────────────────────────────────────
  # Lê o arquivo /sys/class/power_supply/<device>/capacity para saber
  # a bateria, e /status para saber se está carregando.
  # Se o controle tiver Bluetooth, tenta pegar o nome dele.
  notifyScript = pkgs.writeShellApplication {
    name = "controller-battery-notify";
    runtimeInputs = with pkgs; [ bluez libnotify ];
    text = ''
      device="''${1}"
      [ -z "$device" ] && exit 0
      ps="/sys/class/power_supply/$device"
      [ -d "$ps" ] || exit 0
      cap=$(cat "$ps/capacity" 2>/dev/null) || exit 0
      stat=$(cat "$ps/status" 2>/dev/null || echo "Desconhecido")

      name="Controle"
      mac=$(echo "$device" | grep -oP '(?<=ps-controller-battery-|xpadneo-)[0-9a-f]{2}(:[0-9a-f]{2}){5}' || true)
      if [ -n "$mac" ]; then
        bt_name=$(bluetoothctl info "$mac" 2>/dev/null | grep -i "Name:" | sed 's/.*Name: //' | head -1)
        [ -n "$bt_name" ] && name="$bt_name"
      fi

      notify-send -t 5000 "$name" "Bateria: ''${cap}% (''${stat})"
    '';
  };
in {
  home.packages = [ notifyScript ];

  # ── SERVIÇO SYSTEMD (USUÁRIO) ──────────────────────────────────────────
  # Ativado pelo udev quando um controle conecta.
  # O %i é o nome do dispositivo (ex: ps-controller-battery-XX:XX:XX:XX:XX:XX)
  systemd.user.services."controller-battery-notify@" = {
    Unit = {
      Description = "Notifica bateria do controle conectado";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${notifyScript}/bin/controller-battery-notify %i";
    };
  };
}
