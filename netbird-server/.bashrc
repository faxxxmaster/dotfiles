# faxxxmaster 10/2026
# netbird
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fdfind --type d --hidden --follow --exclude .git'
export MICRO_TRUECOLOR=1


HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups   # keine Duplikate, keine Leerzeichen
HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
shopt -s histappend                 # History nicht überschreiben, anhängen

export EDITOR=micro
export VISUAL=micro


# Farben definieren
FG_CYAN='\[\033[01;36m\]'
FG_GREEN='\[\033[01;32m\]'
FG_RED='\[\033[01;31m\]'
FG_BLUE='\[\033[01;34m\]'
FG_NONE='\[\033[00m\]'


prompt_status() {
    local EXIT="$?"
    [ $EXIT -ne 0 ] && echo "✘ $EXIT "
}


# Kompakter, stabiler Farb-Prompt
PS1='\[\033[01;31m\]$(prompt_status)\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '


# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ll='ls -lah --color=auto'
alias la='ls -A'
alias l='ls -CF'

alias version='apt-cache policy'

# Sicherheitsnetz
#alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias fd='fdfind'
alias fd.='fdfind -H'
alias rg='rg --color=auto'
alias rg.='rg -. --color=auto'
alias df='df -h'
alias du='du -sh'

alias free='free -h'
alias ports='ss -tulnp'           # offene Ports anzeigen
alias myip='curl -4 ifconfig.me'
alias upgrade='sudo apt update && sudo apt upgrade -y'
# Caddy bequem verwalten: Prüfen und Reloaden
alias decisions-list='watch -n 2 sudo cscli decisions list'

# Verzeichnis erstellen und direkt rein
mkcd() { mkdir -p "$1" && cd "$1"; }

# Datei/Ordner suchen
f() { find . -name "*$1*" 2>/dev/null; }

# Schnell Prozess killen
pskill() { kill $(pgrep "$1"); }

# Letzten Befehl als root wiederholen
alias pls='sudo $(history -p !!)'

# Extrahieren – egal welches Archiv
extract() {
    case "$1" in
        *.tar.gz|*.tgz)  tar xzf "$1" ;;
        *.tar.bz2)       tar xjf "$1" ;;
        *.tar.xz)        tar xJf "$1" ;;
        *.zip)           unzip "$1" ;;
        *.gz)            gunzip "$1" ;;
        *.7z)            7z x "$1" ;;
        *)               echo "Unbekanntes Format: $1" ;;
    esac
}

caddy-reload() {
    echo "🔍 Prüfe Caddy-Konfiguration..."
    if caddy validate --config /etc/caddy/Caddyfile; then
        echo "✅ Konfiguration valide. Formatiere Datei..."
        caddy fmt --overwrite /etc/caddy/Caddyfile
        echo "🚀 Wende Änderungen an..."
        caddy reload --config /etc/caddy/Caddyfile
         if systemctl is-active --quiet caddy; then
            echo "✨ Fertig! Caddy läuft mit der BETRIEB  Konfiguration."
        else
            echo "❌ Caddy ist nach dem Restart nicht aktiv!"
            journalctl -u caddy -n 20 --no-pager
            return 1
        fi
    else
        echo "❌ Fehler im Caddyfile! Reload abgebrochen."
        return 1
    fi
}

caddy-wartung-reload() {
    echo "🔍 Prüfe Caddy-Konfiguration..."
    if caddy validate --config /etc/caddy/Caddyfile.wartung; then
        echo "✅ Konfiguration valide. Formatiere Datei..."
        caddy fmt --overwrite /etc/caddy/Caddyfile.wartung
        echo "🚀 Wende Änderungen an..."
        caddy reload --config /etc/caddy/Caddyfile.wartung
        if systemctl is-active --quiet caddy; then
            echo "✨ Fertig! Caddy läuft mit der WARTUNG Konfiguration."
        else
            echo "❌ Caddy ist nach dem Restart nicht aktiv!"
            journalctl -u caddy -n 20 --no-pager
            return 1
        fi
    else
        echo "❌ Fehler im Caddyfile! Reload abgebrochen."
        return 1
    fi
}

# Yazi (file manager mit cd-on-exit)
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

# /etc/bash/*.sh einlesen
for f in /etc/bash/*.sh; do
    [ -r "$f" ] && . "$f"
done

unset f

# FZF (Ctrl+T: Dateien, Alt+C: Verzeichnisse, Ctrl+R: History)
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
if command -v fzf &>/dev/null; then
    eval "$(fzf --bash)"
fi

# Zoxide (smart cd) - interaktiv via: zi
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash)"
fi


[ -f ~/.bash_logs ] && source ~/.bash_logs
