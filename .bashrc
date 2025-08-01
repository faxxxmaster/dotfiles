
###################################################
# angepasst von Faxxxmaster
# Debian oder Archlinux Server optimiert
# 20.06.2025
###################################################

iatest=$(expr index "$-" i)

if [ -f /usr/bin/fastfetch ]; then
    fastfetch --config /usr/share/fastfetch/presets/examples/21
 fi

 # Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Enable bash programmable completion features in interactive shells
 if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
 elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi


#############################
#PROMPT
###########################
if [[ $EUID -eq 0 ]]; then
  # Root (rot)
  USER_COLOR='\[\e[1;31m\]'
else
  # Normaler Benutzer (grün)
  USER_COLOR='\[\e[1;32m\]'
fi

HOST_COLOR='\[\e[1;36m\]'    # Cyan
TIME_COLOR='\[\e[1;35m\]'    # Magenta
DIR_COLOR='\[\e[1;33m\]'     # Gelb
PROMPT_COLOR='\[\e[1;36m\]'  # Für die Linien
RESET='\[\e[0m\]'

PS1="${PROMPT_COLOR}┌─[${USER_COLOR}\u${RESET}@${HOST_COLOR}\h${PROMPT_COLOR}] ${TIME_COLOR}\t ${DIR_COLOR}\w${RESET}\n${PROMPT_COLOR}└─ > ${RESET}"


#######################################################
# EXPORTS files
#######################################################

# Disable the bell
if [[ $iatest -gt 0 ]]; then bind "set bell-style visible"; fi

# Expand the history size
export HISTFILESIZE=10000
export HISTSIZE=500
export HISTTIMEFORMAT="%F %T" # add timestamp to history

# Don't put duplicate lines in the history and do not add lines that start with a space
export HISTCONTROL=erasedups:ignoredups:ignorespace

# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS
shopt -s checkwinsize

# Causes bash to append to history instead of overwriting it so if you start a new terminal, you have old session history
shopt -s histappend
PROMPT_COMMAND='history -a'

# set up XDG folders
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Seeing as other scripts will use it might as well export it
export LINUXTOOLBOXDIR="$HOME/linuxtoolbox"

# Allow ctrl-S for history navigation (with ctrl-R)
[[ $- == *i* ]] && stty -ixon

# Ignore case on auto-completion
# Note: bind used instead of sticking these in .inputrc
if [[ $iatest -gt 0 ]]; then bind "set completion-ignore-case on"; fi

# Show auto-completion list automatically, without double tab
if [[ $iatest -gt 0 ]]; then bind "set show-all-if-ambiguous On"; fi

# Set the default editor


export EDITOR=micro
export VISUAL=micro
#alias pico='edit'
#alias spico='sedit'
#alias nano='edit'
#alias snano='sedit'


#sudo
alias sudo='sudo '

# Zellij
alias zell='bash <(curl -L https://zellij.dev/launch)'

#pastebin echo xyz | tb
alias tb='nc termbin.com 9999'

#editoren
alias vim='nvim'
alias edit="micro"

#chri titus linuxtool
alias dasdingdev='curl -fsSL https://christitus.com/linuxdev | sh'
alias dasding='curl -fsSL https://christitus.com/linux | sh'

alias yes='for i in $(seq $(nproc)); do yes > /dev/null & done'

#fzf suchen
alias fzf-rg="ftext"
alias fzf-dir='cd $(fd . -type d | fzf --preview "eza -la {}")'
alias fzf-micro='fd . / | fzf --preview "bat --color=always {}" | xargs -I {} micro {}'
alias fzf-nvim='fd . / | fzf --preview "bat --color=always {}" | xargs -I {} nvim {}'

#Festpklatten
alias diskwatch='watch -d -n 1 "grep -e sd[a-z] /proc/diskstats | awk '\''{print \$3,\$6,\$10}'\''"'
alias diskio='watch -d -n1 "iostat -d"'

#wetterausgabe
alias wetter="curl wttr.in/Geilenkirchen?lang=de"

#yay paru clean
alias drycleanup='yay -Qqdt'
alias paru-drycleanup='paru -Qqdt'
alias cleanup='yay -Rns $(yay -Qqdt)'
alias paru-cleanup='paru  -Rns $(yay -Qqdt)'

#yay paru remove
alias remove='yay -Rns'
alias paru-remove='paru -Rns'

#yay paru install ohne abfrage
alias yay='yay --noconfirm'
alias paru='paru --noconfirm'
alias ip='ip --color=auto'

#hw abfrage
alias sysinfo='inxi -Fxz'

#systemd dienste starten/stoppen/status
alias start='sudo systemctl start'
alias stop='sudo systemctl stop'
alias restart='sudo systemctl restart'
alias status='systemctl status'
alias enable='sudo systemctl enable'
alias disable='sudo systemctl disable'

#######################################################
# MACHINE SPECIFIC ALIAS'S
#######################################################

# Alias's for SSH
# alias SERVERNAME='ssh YOURWEBSITE.com -l USERNAME -p PORTNUMBERHERE'

# Alias's to change the directory
#alias web='cd /var/www/html'

# alias to show the date
alias da='date "+%Y-%m-%d %A %T %Z"'

# Alias's to modified commands
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


# Change directory aliases
alias home='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# cd into the old directory
alias bd='cd "$OLDPWD"'

# Remove a directory and all files
alias rmd='/bin/rm  --recursive --force --verbose '

# Alias's for multiple directory listing commands
alias la='exa -Alh --icons'                # show hidden files
alias ls='exa -ah --icons' # add colors and file type extensions
alias lx='ls -lXBh'               # sort by extension
alias lk='ls -lSrh'               # sort by size
alias lc='ls -ltcrh'              # sort by change time
alias lu='ls -lturh'              # sort by access time
alias lr='ls -lRh'                # recursive ls
alias lt='ls -ltrh'               # sort by date
alias lm='ls -alh |more'          # pipe through 'more'
alias lw='ls -xAh'                # wide listing format
alias ll='exa -la --icons'                # long listing format
alias labc='exa -lap --icons'     # alphabetical sort
alias lf="ls -l | egrep -v '^d'"  # files only
alias ldir="ls -l | egrep '^d'"   # directories only
alias lla='exa -Al --icons'                # List and Hidden Files
alias las='exa -A --icons'                 # Hidden Files
alias lls='exa -l --icons'                 # List

# alias chmod commands
alias mx='chmod a+x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

# Search command line history
alias h="history | grep "

# Search running processes
alias p="ps aux | grep "
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"

# Search files in the current folder
alias f="find . | grep "

# Count all files (recursively) in the current folder
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"

# To see if a command is aliased, a file, or a built-in command
alias checkcommand="type -t"

# Show open ports
alias openports='netstat -nape --inet'

# Alias's for safe and forced reboots
alias rebootsafe='sudo shutdown -r now'
alias rebootforce='sudo shutdown -r -n now'

# Alias's to show disk space and space used in a folder
alias diskspace="du -S | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'
alias mountedinfo='df -hT'

# Alias's for archives
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

# Show all logs in /var/log
alias logs="sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"

#clickpaste
alias clickpaste='sleep 5; xdotool type "$(xclip -o -selection clipboard)"'

# alias to cleanup unused docker containers, images, networks, and volumes

alias docker-clean=' \
  docker container prune -f ; \
  docker image prune -f ; \
  docker network prune -f ; \
  docker volume prune -f '


# To have colors for ls and all grep commands such as grep, egrep and zgrep
export CLICOLOR=1
export LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'
#export GREP_OPTIONS='--color=auto' #deprecated

# Check if ripgrep is installed
if command -v rg &> /dev/null; then
    # Alias grep to rg if ripgrep is installed
    alias grep='rg'
else
    # Alias grep to /usr/bin/grep with GREP_OPTIONS if ripgrep is not installed
    alias grep="/usr/bin/grep $GREP_OPTIONS"
fi
unset GREP_OPTIONS

# Color for manpages in less makes manpages a little easier to read
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'



#######################################################
# SPECIAL FUNCTIONS
#######################################################

#tldr online
wasist () {
 curl  "http://cheat.sh/${1}" 2>/dev/null || printf '%s\n' "[ERROR] Something broke"
}


# Extracts any archive(s) (if unp isn't installed)
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


# fzf-rg-micro: mit ripgrep suchen und Auswahl in micro öffnen
ftext() {
 local rg_cmd
 rg_cmd='rg --hidden --no-ignore --glob "!.cache/**" --glob "!**/.bash_history" \
   --column --color=always --smart-case {q} . || :'

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

alias ftext="ftext"


# Copy and go to the directory
cpg() {
    if [ -d "$2" ]; then
    	cp "$1" "$2" && cd "$2"
    else
    	cp "$1" "$2"
    fi
}
alias cpg="cpg"

# Move and go to the directory
mvg() {
    if [ -d "$2" ]; then
    	mv "$1" "$2" && cd "$2"
    else
    	mv "$1" "$2"
    fi
}
alias mvg="mvg"

# Create and go to the directory
mkdirg() {
    mkdir -p "$1"
    cd "$1"
}
alias mvg="mkdg"

# Goes up a specified number of directories  (i.e. up 4)
up() {
    local d=""
    limit=$1
    for ((i = 1; i <= limit; i++)); do
    	d=$d/..
    done
    d=$(echo $d | sed 's/^\///')
    if [ -z "$d" ]; then
    	d=..
    fi
    cd $d
}



# Automatically do an ls after each cd, z, or zoxide
cd ()
{
    if [ -n "$1" ]; then
    	builtin cd "$@" && ls
    else
    	builtin cd ~ && ls
    fi
}

# Returns the last 2 fields of the working directory
pwdtail() {
    pwd | awk -F/ '{nlast = NF -1;print $nlast"/"$NF}'
}

# Show the current distribution
distribution () {
    local dtype="unknown"  # Default to unknown

    # Use /etc/os-release for modern distro identification
    if [ -r /etc/os-release ]; then
        source /etc/os-release
        case $ID in
            fedora|rhel|centos)
                dtype="redhat"
                ;;
            sles|opensuse*)
                dtype="suse"
                ;;
            ubuntu|debian)
                dtype="debian"
                ;;
            gentoo)
                dtype="gentoo"
                ;;
            arch|cachyos)
                dtype="arch"
                ;;
            slackware)
                dtype="slackware"
                ;;
            *)
                # Check ID_LIKE only if dtype is still unknown
                if [ -n "$ID_LIKE" ]; then
                    case $ID_LIKE in
                        *fedora*|*rhel*|*centos*)
                            dtype="redhat"
                            ;;
                        *sles*|*opensuse*)
                            dtype="suse"
                            ;;
                        *ubuntu*|*debian*)
                            dtype="debian"
                            ;;
                        *gentoo*)
                            dtype="gentoo"
                            ;;
                        *arch*)
                            dtype="arch"
                            ;;
                        *slackware*)
                            dtype="slackware"
                            ;;
                    esac
                fi

                # If ID or ID_LIKE is not recognized, keep dtype as unknown
                ;;
        esac
    fi

    echo $dtype
}


DISTRIBUTION=$(distribution)
if [ "$DISTRIBUTION" = "redhat" ] || [ "$DISTRIBUTION" = "arch" ]; then
      alias cat='bat'
else
      alias cat='batcat'
fi

# Show the current version of the operating system
ver() {
    local dtype
    dtype=$(distribution)

    case $dtype in
        "redhat")
            if [ -s /etc/redhat-release ]; then
                cat /etc/redhat-release
            else
                cat /etc/issue
            fi
            uname -a
            ;;
        "suse")
            cat /etc/SuSE-release
            ;;
        "debian")
            lsb_release -a
            ;;
        "gentoo")
            cat /etc/gentoo-release
            ;;
        "arch")
            cat /etc/os-release
            ;;
        "slackware")
            cat /etc/slackware-version
            ;;
        *)
            if [ -s /etc/issue ]; then
                cat /etc/issue
            else
                echo "Error: Unknown distribution"
                exit 1
            fi
            ;;
    esac
}

#########################
#micro settings
#########################


# Automatically install the needed support files for this .bashrc file
install_tools() {
    local dtype
    dtype=$(distribution)

    case $dtype in
    	"redhat")
    		sudo yum install multitail tree zoxide trash-cli fzf bash-completion fastfetch
    		;;
    	"suse")
    		sudo zypper install multitail tree zoxide trash-cli fzf bash-completion fastfetch
    		;;
    	"debian")
    		sudo apt-get install multitail tree zoxide trash-cli fzf bash-completion curl git ripgrep micro btop duf gdu exa net-tools rsync nala colordiff
    		# Fetch the latest fastfetch release URL for linux-amd64 deb file
    		FASTFETCH_URL=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest | grep "browser_download_url.*linux-amd64.deb" | cut -d '"' -f 4)

    		# Download the latest fastfetch deb file
    		curl -sL $FASTFETCH_URL -o /tmp/fastfetch_latest_amd64.deb

    		# Install the downloaded deb file using apt-get
    		sudo apt-get install /tmp/fastfetch_latest_amd64.deb


    		;;
    	"arch")
    		yay -S multitail tree zoxide trash-cli fzf bash-completion fastfetch ripgrep curl git micro btop duf gdu eza bat unp colordiff

    		;;
    	"slackware")
    		echo "No install support for Slackware"
    		;;
    	*)
    		echo "Unknown distribution"
    		;;
    esac
}

# IP address lookup
alias whatismyip="whatsmyip"
function whatsmyip () {
    # Internal IP Lookup.
    if command -v ip &> /dev/null; then
        echo -n "Internal IP: "
        ip addr show wlan0 | grep "inet " | awk '{print $2}' | cut -d/ -f1
    else
        echo -n "Internal IP: "
        ifconfig wlan0 | grep "inet " | awk '{print $2}'
    fi

    # External IP Lookup
    echo -n "External IP: "
    curl -s ifconfig.me
}



# Trim leading and trailing spaces (for scripts)
trim() {
    local var=$*
    var="${var#"${var%%[![:space:]]*}"}" # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}" # remove trailing whitespace characters
    echo -n "$var"
}


#fzf Auto-Vervollständigung von Dateien/Verzeichnissen mit STRG + T
_fzf_complete() {
    local result=$(find . -type f -o -type d 2>/dev/null | fzf --height=40% --reverse --border --info=inline)
    if [[ -n "$result" ]]; then
        READLINE_LINE="$READLINE_LINE$result"
        READLINE_POINT=${#READLINE_LINE}
    fi
}

bind -x '"\C-t": "_fzf_complete"'


# fzf History-Suche Konfiguration mit STRG + R
if [ -f ~/.fzf.bash ]; then
    source ~/.fzf.bash
fi

source <(fzf --bash)
#oder wenn fzf zu alt und Fehler meldet. Erst gucken wo die Files liegen!
#source /usr/share/doc/fzf/examples/key-bindings.bash



# fzf zoxide suche mit STRG + F
fzf_zoxide() {
    local dir
    dir=$(zoxide query -l | fzf --height=40% --reverse --border --info=inline) && cd "$dir"
}
bind -x '"\C-f": "fzf_zoxide"'



# CTRL-R - Paste the selected command from history into the command line
__fzf_history__() {
  local output
  output=$(
    builtin fc -lnr -2147483648 |
      last_hist=$(HISTTIMEFORMAT='' builtin history 1) perl -n -l0 -e 'BEGIN { getc; $/ = "\n\t"; $HISTCMD = $ENV{last_hist} + 1 } s/^[ *]//; print $HISTCMD - $. . "\t$_" if !$seen{$_}++' |
      FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort,ctrl-z:ignore $FZF_CTRL_R_OPTS --query=${READLINE_LINE:-}" fzf --read0
  ) || return
  READLINE_LINE=${output#*$'\t'}
  if [ -z "$READLINE_POINT" ]; then
    echo "$READLINE_LINE"
  else
    READLINE_POINT=0x7fffffff
  fi
}

# Bind CTRL-R to fzf history search
if [[ $- =~ i ]]; then
    bind -x '"\C-r": __fzf_history__'
fi


# Check if the shell is interactive
if [[ $- == *i* ]]; then
    # Bind Ctrl+f to insert 'zi' followed by a newline
    bind '"\C-f":"zi\n"'
fi

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

export PATH=$PATH:"$HOME/.local/bin:$HOME/.cargo/bin:/var/lib/flatpak/exports/bin:/.local/share/flatpak/exports/bin"

eval "$(zoxide init bash)"
#falls Homebrew installiert ist
#eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
