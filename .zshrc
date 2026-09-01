####################################
# angepasst von Faxxxmaster
# ZSH Konfiguration
# 01.09.2026
##################################################

# Fastfetch starten falls verfügbar

echo
if [ -f /usr/bin/fastfetch ]; then
#    fastfetch --config examples/13
fastfetch --config ~/.config/fastfetch/meine/config.jsonc
fi
echo

# ZSH Konfiguration
setopt AUTO_CD              # cd ohne 'cd' eingeben
setopt CORRECT              # Korrekturvorschläge für Befehle
setopt HIST_IGNORE_ALL_DUPS # Keine doppelten Einträge in History
setopt HIST_IGNORE_SPACE    # Befehle mit führendem Leerzeichen ignorieren
setopt HIST_VERIFY          # History-Expansion vor Ausführung anzeigen
setopt INC_APPEND_HISTORY   # History sofort speichern
setopt SHARE_HISTORY        # History zwischen Sessions teilen
setopt EXTENDED_GLOB        # Erweiterte Glob-Patterns
setopt PROMPT_SUBST         # Variable Expansion in Prompts
setopt HIST_REDUCE_BLANKS   # Enfertn ueberflüssige leereichen


# History-Konfiguration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Autocompletion
autoload -Uz compinit
compinit

bindkey "^[[3~" delete-char         # entf
bindkey "^[[H" beginning-of-line    # Home
bindkey "^[[F" end-of-line          # End
bindkey "^[[5~" beginning-of-history # Page Up
bindkey "^[[6~" end-of-history       # Page Down

# Completion-Stil
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*' rehash true

#############################
# PROMPT
###########################
autoload -U colors && colors

# Benutzer-spezifische Farben
if [[ $EUID -eq 0 ]]; then
    USER_COLOR="%{$fg_bold[red]%}"      # Root (rot)
else
    USER_COLOR="%{$fg_bold[green]%}"    # Normaler Benutzer (grün)
fi

HOST_COLOR="%{$fg_bold[cyan]%}"         # Cyan
TIME_COLOR="%{$fg_bold[magenta]%}"      # Magenta
DIR_COLOR="%{$fg_bold[yellow]%}"        # Gelb
PROMPT_COLOR="%{$fg_bold[cyan]%}"       # Für die Linien
RESET="%{$reset_color%}"
ERROR_COLOR=$'\e[1;31m'     # Rot

# Exit-Code Funktion
prompt_status() {
    local code=$?
    if [ $code -ne 0 ]; then
        echo "${ERROR_COLOR}✘ ${code} ${RESET}"
    fi
}

# Prompt
PROMPT='${PROMPT_COLOR}┌─[${USER_COLOR}%n${RESET}@${HOST_COLOR}%m${PROMPT_COLOR}] ${TIME_COLOR}%D{%H:%M:%S} ${DIR_COLOR}%~${RESET}
${PROMPT_COLOR}└─ $(prompt_status)> ${RESET}'


# PROMPT="${PROMPT_COLOR}┌─[${USER_COLOR}%n${RESET}@${HOST_COLOR}%m${PROMPT_COLOR}] ${TIME_COLOR}%D{%H:%M:%S} ${DIR_COLOR}%~${RESET}
# ${PROMPT_COLOR}└─ > ${RESET}"

#######################################################
# EXPORTS
#######################################################

# XDG Base Directory Specification
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
export XCURSOR_THEME="Bibata-Original-Ice"
# Seeing as other scripts will use it might as well export it
export LINUXTOOLBOXDIR="$HOME/linuxtoolbox"

# Default Editor
export EDITOR=micro
export VISUAL=micro

# Farben für ls und grep
export CLICOLOR=1
export LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'

# Color for manpages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# PATH erweitern
export PATH=$PATH:"$HOME/.local/bin:$HOME/.cargo/bin:/var/lib/flatpak/exports/bin:$HOME/.local/share/flatpak/exports/bin"

#######################################################
# ALIASES
#######################################################

#rsync
alias rsync-daten='rsync -avh --progress --delete --inplace --partial --info=stats1 /home/gcn/DATEN/. /home/gcn/3000/DATEN/. '

# apps
alias davinci='QT_QPA_PLATFORM=xcb GDK_BACKEND=x11 SDL_VIDEODRIVER=x11 davinci-resolve'
alias ff='fastfetch --logo /home/gcn/Dokumente/GitHub/startpage/skull/skull.png --logo-width 41 --logo-height 24'

# webserver
alias http-server='python3 -m http.server'

# yazi fernwartung
alias yazi-docker='yazi sftp://docker'
alias yazi-piflix='yazi sftp://piflix'
alias yazi-backup='yazi sftp://backup'
alias yazi-gc-on-piflix='yazi sftp://gc-on-piflix'

# Sudo
alias sudo='sudo '
alias c='clear'

#ssh Aliases
#alias sshl='kitty +kitten ssh niri@192.168.23.145'

# Zellij
alias zell='bash <(curl -L https://zellij.dev/launch)'

# Pastebin
alias tb='nc termbin.com 9999'

# Editoren
alias vim='nvim'
alias edit="micro"
alias microtv='micro $(tv files)'

# Chris Titus Linux Tools
alias dasdingdev='curl -fsSL https://christitus.com/linuxdev | sh'
alias dasding='curl -fsSL https://christitus.com/linux | sh'

# Tools
alias rofi='rofi -show drun'
alias Plex='Plex --platform xcb'
alias glow='glow -l'

alias yes='for i in $(seq $(nproc)); do yes > /dev/null & done'

# FZF Aliases
alias fzf-rg="ftext"
alias fzf-dir='cd $(fd . -type d | fzf --preview "eza -la {}")'
alias fzf-micro='fd --type f -H --exclude .git --exclude node_modules --exclude "*.bak" . | fzf --preview "bat --color=always {}" | xargs -r -I {} micro {}'


# Festplatten-Monitoring
alias diskwatch='watch -d -n 1 "grep -e sd[a-z] /proc/diskstats | awk '\''{print \$3,\$6,\$10}'\''"'
alias diskio='watch -d -n1 "iostat -d"'

# Wetter
alias wetter='curl "wttr.in/Geilenkirchen?lang=de"'

# Package Management (Arch)
alias drycleanup='paru -Qqdt'

alias cleanup='paru -Rns $(yay -Qqdt)'
alias remove='paru -Rns'


alias paru='paru --noconfirm'

# Network
alias ip='ip --color=auto'

# System Info
alias sysinfo='inxi -Fxz'

# Systemd
alias start='sudo systemctl start'
alias stop='sudo systemctl stop'
alias restart='sudo systemctl restart'
alias status='systemctl status'
alias enable='sudo systemctl enable'
alias disable='sudo systemctl disable'

# Basic aliases
alias da='date "+%Y-%m-%d %A %T %Z"'
alias cp='cp -i'
alias mv='mv -i'
alias rm='trash -v'
alias mkdir='mkdir -p'
alias ps='ps auxf'
alias ping='ping -c 10'
alias less='less -R'
alias cls='clear'
alias apt-get='sudo apt-get'
alias multitail='multitail --no-repeat -c'
alias freshclam='sudo freshclam'
alias vi='nvim'
alias vis='nvim "+set si"'

# Directory navigation
alias home='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias bd='cd "$OLDPWD"'
alias rmd='/bin/rm --recursive --force --verbose'

# Directory listing (mit eza/exa)
alias la='eza -Alh --icons'
alias ls='eza -ah --icons'
alias lx='ls -lXBh'
alias lk='ls -lSrh'
alias lc='ls -ltcrh'
alias lu='ls -lturh'
alias lr='ls -lRh'
alias lt='ls -ltrh'
alias lm='ls -alh | more'
alias lw='ls -xAh'
alias ll='eza -la --icons'
alias labc='eza -lap --icons'
alias lf="ls -l | egrep -v '^d'"
alias ldir="ls -l | egrep '^d'"
alias lla='eza -Al --icons'
alias las='eza -A --icons'
alias lls='eza -l --icons'

# chmod shortcuts
alias mx='chmod a+x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

# Search aliases
alias h="history | grep"
alias p="ps aux | grep"
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"
alias f="find . | grep"
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"
alias checkcommand="type -t"

# Network
alias openports='netstat -nape --inet'

# System control
alias rebootsafe='sudo shutdown -r now'
alias rebootforce='sudo shutdown -r -n now'

# Disk usage
alias diskspace="du -S | sort -n -r | more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'
alias mountedinfo='df -hT'

# Archives
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

# Logs
alias logs="sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"

# Clipboard
alias clickpaste='sleep 5; xdotool type "$(xclip -o -selection clipboard)"'

# Docker cleanup
alias docker-clean='docker container prune -f ; docker image prune -f ; docker network prune -f ; docker volume prune -f'

# IP lookup
alias whatismyip="whatsmyip"

# Iostat
alias iostat="watch -d -n 1 iostat -m -x 1 1"

# Grep mit ripgrep falls verfügbar
if command -v rg &> /dev/null; then
    alias grep='rg'
else
    alias grep="/usr/bin/grep --color=auto"
fi

#######################################################
# SPECIAL FUNCTIONS
#######################################################


# TLDR online
wasist() {
    [[ -z "$1" ]] && { printf '%s\n' "[ERROR] Kein Argument angegeben"; return 1; }
    tldr "$@" 2>/dev/null || curl --silent --location --max-time 10 "https://cheat.sh/${*// //}" || printf '%s\n' "[ERROR] Something broke"
}


# Archive extraction
extract() {
    for archive in "$@"; do
        if [ -f "$archive" ]; then
            case $archive in
                *.tar.bz2) tar xvjf $archive ;;
                *.tar.gz) tar xvzf $archive ;;
                *.bz2) bunzip2 $archive ;;
                *.rar) rar x $archive ;;
                *.gz) gunzip $archive ;;
                *.tar) tar xvf $archive ;;
                *.tbz2) tar xvjf $archive ;;
                *.tgz) tar xvzf $archive ;;
                *.zip) unzip $archive ;;
                *.Z) uncompress $archive ;;
                *.7z) 7z x $archive ;;
                *) echo "don't know how to extract '$archive'..." ;;
            esac
        else
            echo "'$archive' is not a valid file!"
        fi
    done
}

# FZF text search with ripgrep
ftext() {
    local rg_cmd='rg --hidden --no-ignore --glob "!.cache/**" --glob "!**/.bash_history" --column --color=always --smart-case {q} . || :'

    fzf --disabled --ansi \
        --bind "start:reload:$rg_cmd" \
        --bind "change:reload:$rg_cmd" \
        --delimiter=":" \
        --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
        --preview-window '~4,+{2}+4/3,<80(up)' \
        --query="$*" \
        --prompt='Search▶ ' \
    | while IFS=":" read -r file line _; do
        micro "+$line" "$file"
    done
}

# Copy and go to directory
cpg() {
    if [ -d "$2" ]; then
        cp "$1" "$2" && cd "$2"
    else
        cp "$1" "$2"
    fi
}

# Move and go to directory
mvg() {
    if [ -d "$2" ]; then
        mv "$1" "$2" && cd "$2"
    else
        mv "$1" "$2"
    fi
}

# Create and go to directory
mkdirg() {
    mkdir -p "$1"
    cd "$1"
}

# Go up directories
up() {
    local d=""
    local limit=$1
    for ((i = 1; i <= limit; i++)); do
        d=$d/..
    done
    d=$(echo $d | sed 's/^\///')
    if [ -z "$d" ]; then
        d=..
    fi
    cd $d
}

# Auto ls after cd
cd() {
    if [ -n "$1" ]; then
	echo " "
        builtin cd "$@" && ls
	echo " "
    else
	echo " "
        builtin cd ~ && ls
	echo " "
fi
}

# Working directory tail
pwdtail() {
    pwd | awk -F/ '{nlast = NF -1;print $nlast"/"$NF}'
}

# IP address lookup
whatsmyip() {
    if command -v ip &> /dev/null; then
        echo -n "Internal IP: "
        ip addr show wlan0 | grep "inet " | awk '{print $2}' | cut -d/ -f1
    else
        echo -n "Internal IP: "
        ifconfig wlan0 | grep "inet " | awk '{print $2}'
    fi

    echo -n "External IP: "
    curl -s ifconfig.me
}

# Trim whitespace
trim() {
    local var=$*
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    echo -n "$var"
}

#######################################################
# FZF INTEGRATION
#######################################################

# FZF file/directory completion
_fzf_complete() {
    local result=$(find . -type f -o -type d 2>/dev/null | fzf --height=40% --reverse --border --info=inline)
    if [[ -n "$result" ]]; then
        LBUFFER="$LBUFFER$result"
    fi
}

# ZSH key bindings
zle -N _fzf_complete
bindkey '^T' _fzf_complete

# FZF zoxide integration
fzf_zoxide() {
    local dir
    dir=$(zoxide query -l | fzf --height=40% --reverse --border --info=inline) && cd "$dir"
}

zle -N fzf_zoxide
bindkey '^F' fzf_zoxide

#######################################################
# LOAD EXTERNAL TOOLS
#######################################################

# Zoxide (smart cd) - interaktiv via: zi
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

# FZF shell integration (Ctrl+T: Dateien, Alt+C: Verzeichnisse)
if command -v fzf &>/dev/null; then
    source <(fzf --zsh)
fi

# Yazi (file manager mit cd-on-exit)
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

# Öffnet yazi am Ort, den zoxide für das Suchwort findet
zz() {
  if [ -z "$1" ]; then
    yazi
  else
    local dir
    dir=$(zoxide query -- "$1") && cd "$dir" && yazi
  fi
}

# Television (Ctrl+R history search)
eval "$(tv init zsh)"

#######################################################
# FINAL SETUP
#######################################################
source /home/gcn/.local/bin/mount-daten
