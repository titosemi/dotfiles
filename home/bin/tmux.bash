#!/bin/bash

TMUX_SESSION_NAME='JL'
IS_ITERM="$(env | grep -E 'ITERM_SESSION_ID|ITERM_PROFILE' | sed 's/ITERM_SESSION_ID=//;s/ITERM_PROFILE=//' | tr "\n" " " | sed 's/ //g')"
FLAGS=""

if [[ ! -z "$TMUX" ]] || [[ ! -z "$TMUX_PANE" ]]; then
    echo 'You are already attached to a tmux session.'
    echo 'sessions should be nested with care, unset $TMUX to force'
    exit 1
fi

if [[ ! -z "${IS_ITERM}" ]]; then
    FLAGS="-CC"
fi

tmux has-session -t "$TMUX_SESSION_NAME" 2>/dev/null

if [[ "$?" -eq 0 ]]; then
    echo "Session $TMUX_SESSION_NAME already exists. Attaching"
    sleep 1
    #tmux -CC attach-session -t "$TMUX_SESSION_NAME"
    COMMAND="tmux $FLAGS attach-session -t $TMUX_SESSION_NAME"
    eval $COMMAND
    exit 0
fi

# Create the session and do not attach it to the client
tmux new-session -d -s "$TMUX_SESSION_NAME"
tmux rename-window -t 1 "Mac"

tmux new-window -t "$TMUX_SESSION_NAME" -n "VM"
tmux send-keys -t "$TMUX_SESSION_NAME" 'vagrant cd westwing; clear' Enter

# Back to first one
tmux select-window -t 1

# Attach
COMMAND="tmux $FLAGS attach-session -t $TMUX_SESSION_NAME"
eval $COMMAND
