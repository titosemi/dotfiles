# Debug variables
verbose=1
profile_zsh=0

# Debug ZSH load time
test "${profile_zsh}" -eq 1 && zmodload zsh/zprof

# Add our completions
file="${HOME}/.zsh/completions"
test -d "${file}" && fpath=(${file} $fpath) || _sourcing_error "${file}"

# Load Oh My ZSH
_source_file "${HOME}/.oh-my-zsh.rc"

# Fzf integration
_source_file "${HOME}/.fzf.zsh"

# Change Tmux window's name
#if [[ -n "${TMUX}" ]] || [[ -n "${TMUX_PANE}" ]]; then
#    local process="$(tmux display-message -p '#W')"
#    if [[ "${process}" == "reattach-to-user-namespace" ]] || [[ "${process}" == "zsh" ]]; then
#        tmux rename-window $(pwd | rev | cut -d'/' -f1,2 | rev | awk '{print "../" $1}')
#    fi
#fi

test "${profile_zsh}" -eq 1 && zprof

