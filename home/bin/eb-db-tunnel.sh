#!/bin/bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_FILE_FULL="${CURRENT_DIR}/$(basename "${BASH_SOURCE[0]}")"
CURRENT_FILE="$(basename ${CURRENT_FILE_FULL})"
CURRENT_BASE_FILE="$(basename ${CURRENT_FILE_FULL} .sh)"
PARENT_DIR="$(cd "$(dirname "${CURRENT_DIR}")" && pwd)"

VERSION='1.0'

COMMAND=''
APP=''
KEY=''
PORT=3306

DEBUG=false
EB_EB_VARS=''
RDS_HOST=''
RDS_PORT=3306
EC2_USER='ec2-user'
EC2_IP=
PID=''

FILE_PATH="/tmp"
FILE_PATTERN="eb-db-tunnel-"
SSH_ENV_VAR='EB_DB_TUNNEL='

header() {
    echo "eb-db-tunnel v${VERSION} (c) Josemi Liébana <office@josemi-liebana.com>"
    echo ""
}

usage() {
    cat << EOF
Usage: ${CURRENT_BASE_FILE} <command> [<application>] [options]
    command:
        - status                Shows status of current ssh tunnels
        - up <application>      Establish a ssh tunnel to the specified application  
        - down [application]    Closes any existing ssh tunnel.
                                    If an application application is provided,
                                    it will only close that application.
                                    Otherwise it will close all ssh tunnels.
        - usage | help          Displays this message

    options:
        -k | --key              Specifies the key
        -p | --port             Specifies the local port for the tunnel
        -d | --debug            Enables debug. Sets mode -x
        -h | --help             Displays this message

EOF
}

debug() {
    if [[ "${DEBUG}" = true ]]; then
        set -x
    fi
}

message_no_command() {
    echo "No command specified."
}

message_unvalid_command() {
    echo "${COMMAND} is not a valid command."
}

message_no_application() {
    echo "No application was specified."
}

message_no_tunnel() {
    echo "No ssh tunnel is currently active."
}

message_tunnel_running() {
    echo "There is already an active ssh tunnel for the application: ${APP}."
}

message_eb_folder() {
    echo "The eb shh command wasn't successful. Are you in the right folder?."
}

message_no_key() {
    echo "No key has been specified."
}

_call_message() {
    local function="$1"
    shift
    
    "message_${function}" "$@"
}

_error() {
    exit 1
}

_exit() {
    exit 0
}

message_and_error() {
    _call_message "$@"   
    _error
}

message_usage_and_error() {
    _call_message "$@"   
    echo ""
    usage
    _error
}

message_and_exit() {
    _call_message "$@"
    
    _exit
}

_get_path() {
    echo "${FILE_PATH}/${FILE_PATTERN}"
}

_get_app_path() {
    if [[ -z "${APP}" ]]; then
        message_and_error "no_application"
    fi

    echo "$(_get_path)"
}

get_sock_path() {
    echo "$(_get_app_path)${APP}.sock"
}

get_ip_path() {
    echo "$(_get_app_path)${APP}.ip"
}

get_app_files_pattern() {
    echo "$(_get_app_path)${APP}.*"   
}

validate_command() {
    local valid=false

    case "${COMMAND}" in
        status|down|up)
            valid=true
            ;;
        usage|help)
            valid=true
            ;;
    esac

    if [[ "${valid}" != true ]]; then
        message_usage_and_error "unvalid_command"
    fi
}

validate_command_up() {
    local valid=false

    if [[ -z "${APP}" ]]; then
        message_usage_and_error "no_application"
    fi

    if [[ -z "${KEY}" ]]; then
        message_usage_and_error "no_key"
    fi

}

parse_parameters() {
    
    if [[ $# -ge 1 ]]; then
        COMMAND="$1"
        validate_command "${COMMAND}"
        shift
    else
        message_usage_and_error "no_command"
    fi

    if [[ $# -ge 1 ]]; then
        APP="$1"
    fi

    if [[ $# -ge 1 ]]; then
        while [[ $# -ge 1 ]]; 
        do
            case "$1" in
                --key=*|-k=*)
                    KEY="$(echo $1 | sed 's/--key=//' | sed 's/-k=//')"
                    shift
                    ;;
                --port=*|-p=*)
                    PORT="$(echo $1 | sed -e 's/--port=//' -e 's/-p=//')"
                    shift
                    ;;
                --help|-h)
                    usage
                    _exit
                    ;;
                --debug|-d)
                    DEBUG=true
                    shift
                    ;;
                *)
                    shift
                    ;;
            esac
        done
    fi
    
    case "${COMMAND}" in
        up)
            validate_command_up "$1"
            shift
            ;;
    esac
}

command_help() {
    usage
}

command_usage() {
    usage
}

command_status() {
    output="$(ps ax | grep "${FILE_PATTERN}*" | grep -vE "grep|${CURRENT_FILE}" | awk '{print "  [UP] APP: " $10 " PORT: " $15}' | sed -e "s/SendEnv=${SSH_ENV_VAR}//" | cut -d':' -f 1-3)"

    if [[ -z "${output}" ]]; then
        message_and_exit "no_tunnel"
    fi
    
    echo "${output}"
}

command_up() {
    local pid=''

    if [[ -S "$(get_sock_path)" && -f "$(get_ip_path)" ]]; then
        ssh -S "$(get_sock_path)" -O check ec2-user@"$(cat $(get_ip_path))"
    
        if [[ $? -eq 0  ]]; then
            message_and_exit "tunnel_running"
        fi
    fi

    EB_VARS="$(eb ssh ${APP} --number 1 --command 'echo "EC2_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)" && sudo docker exec  $(sudo docker ps -q) env;' | grep -E "RDS|EC2" | grep -v "INFO")"
 
    if [[ $? -ne 0 ]]; then
        message_and_error "eb_folder"
    fi
    
    RDS_HOSTNAME="$(echo "${EB_VARS}" | grep 'RDS_HOSTNAME' | sed 's/RDS_HOSTNAME=//')";
    RDS_PORT=$(echo "${EB_VARS}" | grep 'RDS_PORT' | sed 's/RDS_PORT=//');
    EC2_IP="$(echo "${EB_VARS}" | grep 'EC2_IP' | sed 's/EC2_IP=//')";

    ssh -M -S "$(get_sock_path)" -o "SendEnv=${SSH_ENV_VAR}${APP}" -i "~/.ssh/${KEY}.pem" -f -L ${PORT}:"${RDS_HOSTNAME}":${RDS_PORT} "${EC2_USER}"@"${EC2_IP}" -N 1>/dev/null 2>/dev/null
    pid=$!

    if [[ $? -ne 0 ]]; then
        echo "Error while creating the tunnel"
        kill -9 ${pid} 
        error
    fi

    echo "${EC2_IP}" > "$(get_ip_path)"
    echo "${EB_VARS}"
}

command_down() {
    local active=''
    local pids=''

    if [[ -n "${APP}" ]]; then
        test -S "$(get_sock_path)"
    else
        pids=$(pgrep -f "${FILE_PATTERN}")
    fi

    active="$?"

    if [[ "${active}" -ne 0 ]]; then
        message_no_tunnel
    fi

    if [[ -n "${APP}" ]]; then
        ssh -S "$(get_sock_path)" -O stop "${EC2_USER}"@"$(cat $(get_ip_path))"
        rm -f $(get_app_files_pattern)
    else
        if [[ "${active}" -eq 0 ]]; then 
            kill -9 $(echo ${pids} | tr "\n" " ")
        fi

        rm -f $(_get_path)*
    fi
}

main() {
    header
    parse_parameters "$@"
    debug
    "command_${COMMAND}"
    _exit
}

main "$@"

