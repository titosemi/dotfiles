# Load FZF completions and key-bindings

#fzf_path="$(brew --prefix fzf)"
fzf_path="/usr/share/fzf"

#file="${fzf_path}/shell/completion.zsh"
file="${fzf_path}/completion.zsh"
test -e "${file}" && source "${file}" || echo "File not found: ${file} Skipping sourcing."

#file="${fzf_path}/shell/key-bindings.zsh"
file="${fzf_path}/key-bindings.zsh"
test -e "${file}" && source "${file}" || echo "File not found: ${file} Skipping sourcing."
