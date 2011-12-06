# Load fisrt git completion because we are using it in the promt!
if [[ "$OSTYPE" =~ ^darwin ]]; then
    GIT_COMPLETION="/usr/local/git/contrib/completion/git-completion.bash";
    GITFLOW_COMPLETION="/usr/local/git-flow-completion/git-flow-completion.bash";
else
    GIT_COMPLETION="/etc/bash_completion.d/git";
fi

source "${GIT_COMPLETION}"; 

# Load all the .bash_* files excluding this file
for file in $(ls -a ${HOME}/ |grep .bash_ |grep -v .bash_profile |grep -v .bash_history); do

    if [ -r "${HOME}/$file" ]; then
        source "${HOME}/$file";
    fi

done
unset file

