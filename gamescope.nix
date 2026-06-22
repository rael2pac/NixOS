{ config, pkgs, ... }:

let
  niri = "${pkgs.niri}/bin/niri";

  refresh-apps = pkgs.writeShellScriptBin "refresh-apps" ''
    kbuildsycoca6 --noincremental
    pkill noctalia-shell 2>/dev/null || true
    sleep 0.3
    ${niri} msg action spawn -- "noctalia-shell"
  '';

  gamescope-run = pkgs.writeShellScriptBin "gamescope-run" ''
    exec gamemoderun gamescope \
      --force-grab-cursor \
      -b \
      -- "$@"
  '';

  gamescope-auto = pkgs.writeShellScriptBin "gamescope-auto" ''
    output="$(${niri} msg focused-output 2>/dev/null)" || output=""
    res=$(echo "$output" | sed -n 's/.*Current mode: \([0-9]\+\)x\([0-9]\+\).*/\1 \2/p')
    hz=$(echo "$output"  | sed -n 's/.*@ \([0-9]\+\)\.[0-9]\+ Hz.*/\1/p')
    width=$(echo "$res" | cut -d' ' -f1)
    height=$(echo "$res" | cut -d' ' -f2)

    exec gamemoderun gamescope \
      -w "''${width:-1920}" -h "''${height:-1080}" \
      -W "''${width:-1920}" -H "''${height:-1080}" \
      -r "''${hz:-144}" \
      -f \
      --force-grab-cursor \
      -- "$@"
  '';
in
{
  home.packages = [ refresh-apps gamescope-run gamescope-auto ];
}
