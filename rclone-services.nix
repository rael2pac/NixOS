# ===========================================================================
# SERVIÇOS RCLONE — Montagem automática de nuvens
# ===========================================================================
# Cria serviços systemd que montam automaticamente Google Drive, Mega e
# OneDrive via Rclone na inicialização do sistema.
#
# Pré-requisitos:
#   1. rclone.conf configurado em ~/.config/rclone/rclone.conf
#   2. Os remotes "Gdrive:", "Mega:" e "Onedrive:" devem existir
#
# Comandos úteis:
#   systemctl start rclone-gdrive     → monta agora
#   systemctl stop rclone-gdrive      → desmonta
#   journalctl -u rclone-gdrive -f    → ver logs
# ===========================================================================
{ config, pkgs, ... }:

{
  # Libera o FUSE para montagens de usuários comuns
  programs.fuse.userAllowOther = true;

  # Garante os pacotes base instalados no sistema
  environment.systemPackages = [ pkgs.rclone pkgs.fuse3 ];

  # Garante que as pastas de montagem existam
  systemd.tmpfiles.rules = [
    "d /home/rael/Rclone/Gdrive 0755 rael users -"
    "d /home/rael/Rclone/Mega 0755 rael users -"
    "d /home/rael/Rclone/Onedrive 0755 rael users -"
  ];

  # ── SERVIÇOS SYSTEMD ───────────────────────────────────────────────────
  systemd.services = {

    # ── GOOGLE DRIVE ─────────────────────────────────────────────────────
    rclone-gdrive = {
      description = "Servico Nativo Rclone - Gdrive";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];
      path = [ pkgs.fuse3 pkgs.rclone ];

      serviceConfig = {
        Type = "simple";
        User = "rael";
        Group = "users";
        Environment = "PATH=/run/wrappers/bin";
        ExecStart = ''
          ${pkgs.rclone}/bin/rclone mount Gdrive: /home/rael/Rclone/Gdrive \
            --config=/home/rael/.config/rclone/rclone.conf \
            --vfs-cache-mode full \
            --vfs-cache-mode writes \
            --vfs-cache-max-age 5m \
            --vfs-read-chunk-size 128M \
            --vfs-read-chunk-size-limit 1G \
            --allow-other \
            --allow-non-empty \
            --dir-cache-time 72h \
            --poll-interval 15s \
            --buffer-size 64M
        '';
        ExecStop = "/run/wrappers/bin/fusermount3 -u /home/rael/Rclone/Gdrive";
        Restart = "on-failure";
        RestartSec = "10s";
      };
    };

    # ── MEGA ─────────────────────────────────────────────────────────────
    rclone-mega = {
      description = "Servico Nativo Rclone - Mega";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];
      path = [ pkgs.fuse3 pkgs.rclone ];

      serviceConfig = {
        Type = "simple";
        User = "rael";
        Group = "users";
        Environment = "PATH=/run/wrappers/bin";
        ExecStart = ''
          ${pkgs.rclone}/bin/rclone mount Mega: /home/rael/Rclone/Mega \
            --config=/home/rael/.config/rclone/rclone.conf \
            --vfs-cache-mode writes \
            --vfs-cache-max-age 5m \
            --vfs-read-chunk-size 128M \
            --vfs-read-chunk-size-limit 1G \
            --allow-other \
            --allow-non-empty \
            --dir-cache-time 72h \
            --poll-interval 15s \
            --buffer-size 64M
        '';
        ExecStop = "/run/wrappers/bin/fusermount3 -u /home/rael/Rclone/Mega";
        Restart = "on-failure";
        RestartSec = "10s";
      };
    };

    # ── ONEDRIVE ─────────────────────────────────────────────────────────
    rclone-onedrive = {
      description = "Servico Nativo Rclone - OneDrive";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];
      path = [ pkgs.fuse3 pkgs.rclone ];

      serviceConfig = {
        Type = "simple";
        User = "rael";
        Group = "users";
        Environment = "PATH=/run/wrappers/bin";
        ExecStart = ''
          ${pkgs.rclone}/bin/rclone mount Onedrive: /home/rael/Rclone/Onedrive \
            --config=/home/rael/.config/rclone/rclone.conf \
            --vfs-cache-mode writes \
            --vfs-cache-max-age 5m \
            --vfs-read-chunk-size 128M \
            --vfs-read-chunk-size-limit 1G \
            --allow-other \
            --allow-non-empty \
            --dir-cache-time 72h \
            --poll-interval 15s \
            --buffer-size 64M
        '';
        ExecStop = "/run/wrappers/bin/fusermount3 -u /home/rael/Rclone/Onedrive";
        Restart = "on-failure";
        RestartSec = "10s";
      };
    };
  };
}
