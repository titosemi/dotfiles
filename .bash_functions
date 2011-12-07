#!/bin/bash

# Functions just for MAC
if [[ "$OSTYPE" =~ ^darwin ]]; then

    quit () {
        for app in $*; do
            osascript -e 'quit app "'$app'"'
        done
    }

    pman() { man -t "${1}" | open -f -a Preview; }

fi
