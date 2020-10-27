#!/bin/bash

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
    echo "[.profile] ${1}"
}

shell_config_path="${HOME}/.config/shell"

# Load the exports
_source_file "${shell_config_path}/exportrc"

# Load my functions
_source_file "${shell_config_path}/functionrc"

# Load my aliases
_source_file "${shell_config_path}/aliasrc"

# Load Homeshick
_source_file "${HOMESHICK_DIR}/.homeshick.sh"

shell="$(echo $0)"
case "${shell}" in
    *bash*)
        _source_file "${HOME}/.bashrc"
        ;;
    *zsh*)
        _source_file "${HOME}/.zshrc"
        ;;
esac

# Show the weather (from our functions)
type weather 1>/dev/null && weather

_output "Enjoy your session"

