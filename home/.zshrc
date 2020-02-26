# Debug variables
verbose=1
profile_zsh=0

# Debug ZSH load time
test "${profile_zsh}" -eq 1 && zmodload zsh/zprof

# Private function
function _source_file()
{
    test -z "${1}" &&  _output "file name must be provided"
    test -e "${1}" && source "${1}" || _sourcing_error "${1}"
}
# Private function
function _sourcing_error()
{
    _output "not found: ${1} Skipping sourcing."
}

# Private function
function _output()
{
    echo "[.zshrc] ${1}"
}

# Load the exports.
_source_file "${HOME}/.exportrc"

# Load my functions
_source_file "${HOME}/.functionrc"

# Load my aliases
_source_file "${HOME}/.aliasrc"

# Add our completions
file="${HOME}/.zsh/completions"
test -d "${file}" && fpath=(${file} $fpath) || _sourcing_error "${file}"

# Load Homeshick. 
# It needs to be loaded before ohmyzsh! https://github.com/andsens/homeshick/issues/89
file="${HOMESHICK_DIR}/homeshick.sh"
if test -e "${file}"; then
    source "${file}";
    fpath=($HOME/.homesick/repos/homeshick/completions $fpath)
else
    _sourcing_error "${file}"
fi

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

# Show the weather (function)
type weather 1>/dev/null && weather

test "${profile_zsh}" -eq 1 && zprof

_output "Enjoy your session"

