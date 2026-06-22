# ===========================================================================
# DISCOS — Montagem de Partições Adicionais
# ===========================================================================
# Monta automaticamente os discos extras /mnt/1T e /mnt/4T na inicialização.
#
# AVISO: As UUIDs abaixo são ESPECÍFICAS deste PC.
# Num PC novo, substitua pelas UUIDs corretas do novo hardware.
# Para descobrir: lsblk -f
#
# nofail → não impede o boot se o disco não estiver presente
# ===========================================================================
{ config, pkgs, ... }:

{
  fileSystems."/mnt/1T" = {
    device = "/dev/disk/by-uuid/994e5e3d-0c58-49a6-85aa-629409beb9fe";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  fileSystems."/mnt/4T" = {
    device = "/dev/disk/by-uuid/ae53f12d-bebf-4f41-8b0d-bf9d938f577c";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };
}
