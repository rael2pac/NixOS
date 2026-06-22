# ===========================================================================
# ENERGIA — Gerenciamento de Suspensão
# ===========================================================================
# Configura o logind (gerenciador de sessões do systemd) para suspender
# o computador após 10 minutos de inatividade.
# ===========================================================================
{ ... }:

{
  services.logind.settings.Login = {
    IdleAction = "suspend";         # Ação quando ocioso: suspender
    IdleActionSec = "10min";        # Tempo de inatividade: 10 minutos
  };
}
