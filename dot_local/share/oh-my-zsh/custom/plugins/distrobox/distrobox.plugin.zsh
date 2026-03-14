if (( ! $+commands[distrobox] )); then
  return
fi

# Aliases for distrobox commands (distrobox 1.8.2.4)
alias dba='distrobox assemble'
alias dbc='distrobox create'
alias dbe='distrobox enter'
alias dbls='distrobox list'
alias dbrm='distrobox rm'
alias dbstop='distrobox stop'
alias dbup='distrobox upgrade'
alias dbep='distrobox ephemeral'
alias dbge='distrobox generate-entry'
