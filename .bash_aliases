# Easier navigation: .., ..., ~ and -
alias ..="cd .."
alias ...="cd ../.."
alias ~="cd ~" # `cd` is probably faster to type though
alias -- -="cd -"

# List all files colorized in long format, including dot files
alias la="ls -Gla"

# List only directories
alias lsd='ls -l | grep "^d"'

# Always use color output for `ls`
if [[ "$OSTYPE" =~ ^darwin ]]; then
    alias ls="command ls -G"
else
	alias ls="command ls --color"
fi

# Undo a `git push`
alias undopush="git push -f origin HEAD^:master"

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en1"
alias ips="ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1'"
alias whois="whois -h whois-servers.net"

# File size
alias fs="stat -f \"%z bytes\""

# Aliases just for MAC
if [[ "$OSTYPE" =~ ^darwin ]]; then

    # Shortcuts
    alias d="cd ~/Documents/Dropbox"
    alias p="cd ~/Projects"
    alias g="git"
    alias v="vim"
    alias m="mate ."   

    # Flush Directory Service cache
    alias flush="dscacheutil -flushcache"

    # OS X has no `md5sum`, so use `md5` as a fallback
    type -t md5sum > /dev/null || alias md5sum="md5"

    # Trim new lines and copy to clipboard
    alias c="tr -d '\n' | pbcopy"

    # Recursively delete `.DS_Store` files
    alias cleanup="find . -name '*.DS_Store' -type f -ls -delete" 

    # Empty the Trash
    alias emptytrash="rm -rfv ~/.Trash"

    # Show/hide hidden files in Finder
    alias show="defaults write com.apple.Finder AppleShowAllFiles -bool true && killall Finder"
    alias hide="defaults write com.apple.Finder AppleShowAllFiles -bool false && killall Finder"

    # Hide/show all desktop icons (useful when presenting)
    alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
    alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

    # Disable/Enable Spotlight
    alias spotoff="sudo mdutil -a -i off"
    alias spoton="sudo mdutil -a -i on"

    # Stuff I never really use but cannot delete either because of http://xkcd.com/530/
    alias stfu="osascript -e 'set volume output muted true'"
    alias pumpitup="osascript -e 'set volume 10'"
    alias hax="growlnotify -a 'Activity Monitor' 'System error' -m 'WTF R U DOIN'"

    # Some applications
    alias twitter='/usr/local/bin/ttytter -exts="/usr/local/ttytter/extensions/enhanced_growl/enhanced_growl.pl" -notifytype="enhanced_growl"'
    alias drush='/Applications/drush/drush'

fi    
   
