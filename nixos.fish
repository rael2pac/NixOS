complete -c nixos -f -a "switch"     -d "Aplica nova config AGORA (ativa ja)"
complete -c nixos -f -a "boot"       -d "Aplica nova config no PROXIMO reboot"
complete -c nixos -f -a "test"       -d "Testa config sem alterar perfil atual"
complete -c nixos -f -a "update"     -d "Trava -> reconstroi -> limpa -> otimiza"
complete -c nixos -f -a "limpar"     -d "Limpa lixo + mantem 3 ultimas geracoes"
complete -c nixos -f -a "limpar-tudo" -d "Limpa TUDO (forca remocao total)"
complete -c nixos -f -a "otimizar"   -d "Reorganiza armazem para ocupar menos"
complete -c nixos -f -a "rollback"   -d "Volta para a geracao anterior"
complete -c nixos -f -a "geracoes"   -d "Lista todas as geracoes do sistema"
complete -c nixos -f -a "info"       -d "Versao e caminho do sistema atual"
complete -c nixos -f -a "drift"      -d "Diferenca entre config e sistema real"
complete -c nixos -f -a "hm"         -d "Reconstroi so o Home Manager"
complete -c nixos -f -a "hmu"        -d "HM + limpa + otimiza"

function nixos -d "Gerenciador de comandos NixOS"
  if test (count $argv) -eq 0
    echo "Uso: nixos <comando>"
    echo ""
    echo "Comandos:"
    echo "  switch       Aplica nova config AGORA"
    echo "  boot         Aplica no proximo reboot"
    echo "  test         Testa sem alterar perfil"
    echo "  update       Trava -> reconstroi -> limpa -> otimiza"
    echo "  limpar       GC + mantem 3 ultimas gens"
    echo "  limpar-tudo  Forca limpeza total + otimiza"
    echo "  otimizar     Reorganiza o store"
    echo "  rollback     Volta geracao anterior"
    echo "  geracoes     Lista geracoes do sistema"
    echo "  info         Versao + caminho atual"
    echo "  drift        Diferenca entre config e sistema real"
    echo "  hm           So Home Manager (config do usuario)"
    echo "  hmu          HM + limpa + otimiza"
  else
    switch $argv[1]
      case switch
        sudo nixos-rebuild switch --flake ~/home-manager
      case boot
        sudo nixos-rebuild boot --flake ~/home-manager
      case test
        sudo nixos-rebuild test --flake ~/home-manager
      case update
        nix flake update --flake ~/home-manager
        and sudo nixos-rebuild switch --flake ~/home-manager
        and sudo nix-collect-garbage
        and sudo nix store optimise
      case limpar
        sudo nix-collect-garbage
        and sudo nix-env --delete-generations +3 -p /nix/var/nix/profiles/system
      case limpar-tudo
        sudo nix-collect-garbage -d
        and sudo nix store optimise
      case otimizar
        sudo nix store optimise
      case rollback
        sudo nixos-rebuild switch --rollback --flake ~/home-manager
      case geracoes
        sudo nix-env --list-generations -p /nix/var/nix/profiles/system
      case info
        echo "Versao: "(nixos-version)
        echo "Caminho: "(readlink -f /run/current-system)
      case drift
        sudo nixos-rebuild dry-activate --flake ~/home-manager
      case hm
        sudo nixos-rebuild switch --flake ~/home-manager
      case hmu
        sudo nixos-rebuild switch --flake ~/home-manager
        and nix-collect-garbage
        and nix store optimise
      case '*'
        echo "Comando desconhecido: $argv[1]"
        echo "Digite nixos para ver os comandos disponiveis"
    end
  end
end
