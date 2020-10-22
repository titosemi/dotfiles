#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__file}")" && pwd)"

folder_backgrounds="${HOME}/Dropbox/Images/Backgrounds"
folder_cache="${HOME}/.cache/wallpaper"
file_log="${folder_cache}/wallpaper.log"
file_lock="${folder_cache}/wallpaper.lock"
file_pid="/run/user/$(id -u)/wallpaper.pid"

function cleanup {
    rm "${file_pid}"
}

function instance()
{
    if test -f "${file_pid}"; then
        log "There is an instance already running"
        exit 1
    else
        echo $$ > "${file_pid}"
    fi
}

function setup()
{
    if [[ ! -d "${folder_cache}" ]]; then
        mkdir -p "${folder_cache}"
    fi
}

function check_path()
{
    if [[ ! -d "${folder_backgrounds}" ]]; then
        log "The background folder [${folder_background}] does not exists"

        exit 1
    fi
}


function log()
{
    local date="$(date "+%Y/%m/%d %H:%M:%S")"

    echo "${date}    $1" >> ${file_log}
}

function get_background()
{
    local background="$(ls "${folder_backgrounds}" | sort -R | tail -n1)"

    echo "${folder_backgrounds}/${background}"
}

function set_background()
{
    local background="$1"

    nitrogen --set-zoom-fill "${background}" >> "${file_log}" 2>&1 || true
    echo "${background}" >> "${file_lock}"
}

function change_theme()
{
    local background="$1"

    wal -n -i "${background}" >> "${file_log}" 2>&1 || true
}

function loop()
{
    while true; do
        log "Starting"
        local background="$(get_background)"
        set_background "${background}"
        
        #change_theme "${background}"
        log "Finished"
        sleep 5m
    done
}

function main()
{
    trap cleanup EXIT
    instance
    setup
    check_path
    loop
}

main

