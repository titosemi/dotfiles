#!/bin/bash

function output {

    if [ "$?" -ne 0 ]; then
        echo -e "${MSG} \t\t*** Error ***";
        echo "---------------";
        echo "${OUTPUT}"
        echo -e "---------------\n";
    else
        echo -e "${MSG} \t\t*** OK ***";
    fi

    clean_variables

}

function clean_variables {
    unset OUTPUT
    unset MSG
} 

read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
echo -e "\n";

if [[ $REPLY =~ ^[Yy]$ ]]; then
    
    # Get the name of the current script
    SCRIPT=`basename $0`;

    # If we are in a not in a git repo, initialiate it and update the files
    if [ $(git rev-parse --is-inside-work-tree) != "true" ]; then
        $(git init 2>&1)
        $(git remote add origin git@github.com:titosemi/dotfiles.git 2>&1)
    fi
        
    MSG="Attempting to update repository..."  
    OUTPUT=$(git pull origin master 2>&1)       
    output

    
    # Copy the files
    for file in $(ls -la |grep ^- | awk '{print ($9)}'); do
        # Don't copy this script...
        if [ "$file" != "$SCRIPT" -a "$file" != "README.md" ]; then    
            MSG="Attempting to copy $file ...";
            OUTPUT=$(cp "$file" ${HOME}/"$file" 2>&1)
            output
        fi
    done

    MSG="Attempting to load .bash_profile";
    source "${HOME}/.bash_profile";
    output

    export PROMPT_COMMAND="source ${HOME}/.bash_prompt";

fi
