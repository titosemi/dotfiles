# Load the exports.
file="${HOME}/.exportrc"
test -e "${file}" && source "${file}" || echo "File not found: ${file} Skipping sourcing."

# Load my functions
file="${HOME}/.functionrc"
test -e "${file}" && source "${file}" || echo "File not found: ${file} Skipping sourcing."

# Load my aliases
file="${HOME}/.aliasrc"
test -e "${file}" && source "${file}" || echo "File not found: ${file} Skipping sourcing."

# Add our completions
file="${HOME}/.zsh/completions"
test -d "${name}" && fpath=(${name} $fpath) || echo "File not found: ${file} Skipping sourcing."

# Load Homeshick. 
# It needs to be loaded before ohmyzsh! https://github.com/andsens/homeshick/issues/89
file="${HOMESHICK_DIR}/homeshick.sh"
if test -e "${file}"; then
    source "${file}";
    fpath=($HOME/.homesick/repos/homeshick/completions $fpath)
else
    echo "File not found: ${file} Skipping sourcing."
fi

# Load Oh My ZSH
file="${HOME}/.oh-my-zsh.rc"
test -e "${file}" && source "${file}" || echo "File not found: ${file} Skipping sourcing."

# iTerm2 Shell integration
file="${HOME}/.iterm2_shell_integration.zsh"
test -e "${file}" && source "${file}" || echo "File not found: ${file} Skipping sourcing." 

# Fzf integration
file="${HOME}/.fzf.zsh"
test -e "${file}" && source "${file}" || echo "File not found: ${file} Skipping sourcing."

# Change Tmux window's name
if [[ -n "${TMUX}" ]] || [[ -n "${TMUX_PANE}" ]]; then
    if [[ "$(tmux display-message -p '#W')" == "reattach-to-user-namespace" ]]; then
        tmux rename-window $(pwd | rev | cut -d'/' -f1,2 | rev | awk '{print "../" $1}')
    fi
fi

# Show the weather (function)
type weather 1>/dev/null && weather

