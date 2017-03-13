# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="robbyrussell"

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(brew docker git jira jsontools phing osx taskwarrior tig tmux web-search)

# Homeshick integration - It needs to be loaded before ohmyzsh! https://github.com/andsens/homeshick/issues/89
source "$HOME/.homesick/repos/homeshick/homeshick.sh"
fpath=($HOME/.homesick/repos/homeshick/completions $fpath)

# Load Oh My ZSH
source "$ZSH/oh-my-zsh.sh"

# User configuration
export PATH="$HOME/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin"

# OSX
export PATH="/usr/local/MacGPG2/bin:/opt/X11/bin:/opt/composer/vendor/bin:$PATH"

# Force language environment
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export LC_CTYPE_='en_US.UTF-8'

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='mvim'
 fi

# Use vim as man pager
export MANPAGER="/bin/sh -c \"col -bx | vim -c 'set ft=man nolist nonumber nomodifiable nomodified' -\""

# SSH Yubikey
export SSH_AUTH_SOCK="$HOME/.gnupg/S.gpg-agent.ssh"

# Gihub tokens
# Homebrew
export HOMEBREW_GITHUB_API_TOKEN='bf2a5e6726602ad38df2db6bffb14d69b8c28603'

# iTerm2 Sheel integration
test -e ${HOME}/.iterm2_shell_integration.zsh && source ${HOME}/.iterm2_shell_integration.zsh

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

alias dotfile-reload="source $HOME/.zshrc"
alias dotfile-edit="$EDITOR $HOME/.zshrc"

alias prettyjson='python -m json.tool'

alias fix-gpg="killall -9 scdaemon; killall -9 gpg-agent; gpg --card-status"
alias fix-dns="sudo discoveryutil mdnsactivedirectory yes"

alias rm="rmtrash"

alias cddesk="cd $HOME/Desktop"
alias cddown="cd $HOME/Downloads"
alias cddocs="cd $HOME/Documents"
alias cdwwdocs="cd $HOME/Documents/Westwing"
alias cdww="cd $HOME/Documents/Westwing"
alias cdwip="cd $HOME/Development/WIP"
alias cddev="cd $HOME/Development"
alias cdtmp="cd $HOME/Desktop/tmp"
alias cdwwdev="cd $HOME/Development/Westwing"
alias cddrop="cd $HOME/Dropbox"
alias cddrive="cd $HOME/Google\ Drive"
alias cdmovies="cd $HOME/Movies"
alias cdmusic="cd $HOME/Music"

alias mysql-workbench="open /Applications/MySQLWorkbench.app"

alias wifi-info="/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I"

alias sshuttle="sshuttle -D --pidfile /usr/local/var/run/sshuttle.pid -v "
alias sshuttle-stop='kill $(cat /usr/local/var/run/sshuttle.pid)'
alias sshuttle-log="sudo tail -f /var/log/system.log | grep --line-buffered sshuttle"
alias sshuttle-westwing="sshuttle --dns -r ssh.westwing.eu 0/0"

alias dcs="docker-compose $*"
alias dcl="docker volume rm $(docker volume ls -q -f 'dangling=true') 2>/dev/null; docker rmi $(docker images -f 'dangling=true' -q) 2>/dev/null"

# Docker images
alias composer="docker run -it --rm -v "$(pwd):/app" composer/composer:1.0.0-beta1 $*"
alias phpunit="docker run -it --rm -v "$(pwd):/app" phpunit/phpunit $*"
alias rstudio="docker run -d -v "$(pwd):/home/rstudio" -p 8787:8787 -e USER=rstudio -e PASSWORD=rstudio rocker/rstudio"

# Load Weather
function weather() {
    local cache_file='/tmp/weather.txt'
    local cache=3600
    local update='false'
    local modify=''
    local now=$(date +%s)
    local diff=''

    if [[ ! -f "${cache_file}" ]]; then
        update='true'
    else
        modify="$(stat -f "%m" "${cache_file}" 2>/dev/null)"
        diff=$((now-modify))
        if [[ ${diff} -ge ${cache} ]]; then
            update='true'
        fi
    fi

    if [[ "${update}" == 'true' ]]; then
        curl http://wttr.in/ > "${cache_file}"
    fi

   cat "${cache_file}"
}

function dps()  {
    docker ps $@ --format "table{{ .Names }}\\t{{ .Status }}\\t{{ .Command }}\\t{{ .Image }}\\t{{ .Ports }}" | sort -k1 | awk '
      NR % 2 == 0 {
        printf "\033[0m";
      }
      NR % 2 == 1 {
        printf "\033[1m";
      }
      NR == 1 {
        PORTSPOS = index($0, "PORTS");
        PORTS = "PORTS";
        PORTSPADDING = "\n";
        for(n = 1; n < PORTSPOS; n++)
          PORTSPADDING = PORTSPADDING " ";
      }
      NR > 1 {
        PORTS = substr($0, PORTSPOS);
        gsub(/, /, PORTSPADDING, PORTS);
      }
      {
        printf "%s%s\n", substr($0, 0, PORTSPOS - 1), PORTS;
      }
      END {
        printf "\033[0m";
      }
    '
}

function dpsa() { 
    dps -a $@;
}

weather

