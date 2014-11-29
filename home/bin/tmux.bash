#!/bin/bash

TMUX_SESSION_NAME='JL'

if [[ ! -z "$TMUX" ]] || [[ ! -z "$TMUX_PANE" ]]; then
    exit 1
fi

tmux has-sessions -t "$TMUX_SESSION_NAME" 2>/dev/null

if [ "$?" -eq 0 ]; then
    echo "Session $TMUX_SESSION_NAME already exists. Attaching"
    sleep 1
    tmux attach -t "$TMUX_SESSION_NAME"
    exit 0
fi


# Create the session and do not attach it to the client
tmux new-session -d -s "$TMUX_SESSION_NAME"
tmux rename-window -t 1 "Mac"

tmux new-window -t "$TMUX_SESSION_NAME" -n "VM"
tmux send-keys -t "$TMUX_SESSION_NAME" 'cdvagrant' Enter

# Back to first one
tmux select-window -t 1

# Attach
tmux attach -t "$TMUX_SESSION_NAME"
