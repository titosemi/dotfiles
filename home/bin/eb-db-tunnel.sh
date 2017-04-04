#!/bin/bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_FILE_FULL="${CURRENT_DIR}/$(basename "${BASH_SOURCE[0]}")"
CURRENT_FILE="$(basename ${CURRENT_FILE_FULL})"
CURRENT_BASE_FILE="$(basename ${CURRENT_FILE_FULL} .sh)"
PARENT_DIR="$(cd "$(dirname "${CURRENT_DIR}")" && pwd)"

VERSION='1.0'
CHECKSUM='29155c74cf76d8e2e027292f2005296d5284187de72be2999ae7e78adac9a7e6'
SOURCE_URL='https://raw.githubusercontent.com/titosemi/dotfiles/master/home/bin/eb-db-tunnel.sh'

COMMAND=''
APP=''
KEY=''
PORT=3306
DIR=''
ALIAS=''

DEBUG=false
EB_EB_VARS=''
RDS_HOST=''
RDS_PORT=3306
EC2_USER='ec2-user'
EC2_IP=
PID=''

CONFIG_FILE="${HOME}/.config/eb-db-tunnel.conf"
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
        - status                Shows status of current ssh tunnels.
        - up <application>      Establish a ssh tunnel to the specified application.
        - down [application]    Closes any existing ssh tunnel.
                                    If an application application is provided,
                                    it will only close that application.
                                    Otherwise it will close all ssh tunnels.
        - usage | help          Displays this message.
        - update                Updates the script.

    options:
        -k= | --key=            Specifies the private key. (Don't add the .pem extension)
                                    The key is expected to be located in ~/.ssh/
        -p= | --port=           Specifies the local port for the tunnel.
        -f= | --folder=         Specifies the directory where the elasticbeanstalk configuration resides.

        -a= | --alias=          Specifies an alias from the configuration file.
                                    It has precedence (overrides) over the -k, -p and -f options
                                    The configuration file is expected to be located in ~/.config/eb-db-tunnel.conf
                                    A sample configuration file could looks like:
                                        sample.app=MySample-EB-APP
                                        sample.key=MySample-EB-Key
                                        sample.dir=~/Projects/My-eb-app

        -d | --debug            Enables debug. Sets mode -x.
        -h | --help             Displays this message.

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

message_tunnel_error() {
    echo "The ssh tunnel couldn't be created."
}

message_eb_folder() {
    echo "The eb shh command wasn't successful. Are you in the right folder?."
}

message_no_key() {
    echo "No key has been specified."
}

message_update_error() {
    echo "The update couldn't be successfully perform." 
}

message_update_updated() {
    echo "The update was successfull."
}

message_update_equal() {
    echo "The script is already up-to-date."
}

message_bump_bumped() {
    echo "The checksum was updated. New checksum: $1"
}

message_bump_equal() {
    echo "The checksum didn't changed."
}

message_no_config() {
    echo "No configuration file was found in: ${CONFIG_FILE}"
}

message_no_alias() {
    echo "The alias ${ALIAS} was not found in the configuration file"
}

message_no_dir() {
    echo "The directory ${DIR} doesn't exists"
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
    echo -n "Error: "
    _call_message "$@"   
    _error
}

message_usage_and_error() {
    echo -n "Error: "
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
        update|bump|usage|help)
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

validate_parameters() {
    validate_command "${COMMAND}"

    case "${COMMAND}" in
        up)
            validate_command_up
            shift
            ;;
    esac
}

parse_parameters() {
    if [[ $# -ge 1 ]]; then
        COMMAND="$1"
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
                --folder=*|-f=*)
                    DIR="$(echo $1 | sed -e 's/--folder=//' -e 's/-f=//')"
                    shift
                    ;;
                --alias=*|-a=*)
                    ALIAS="$(echo $1 | sed -e 's/--alias=//' -e 's/-a=//')"
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
}

_set_config_value() {
    local config="$1"
    local key="$2"
    local var="$(echo ${key} | tr '[:lower:]' '[:upper:]')"
    local value=''
 
    value="$(echo "${config}" | grep ".${key}=" | sed "s/.*.${key}=//")"
    if [[ -n "${value}" ]]; then
        printf -v ${var} "${value}"
    fi
}

load_config() {
    local config=''
    local value=''

    if [[ -n "${ALIAS}" ]]; then
        if [[ ! -f "${CONFIG_FILE}" ]]; then
            message_and_error "no_config"
        fi

        config="$(cat ${CONFIG_FILE} | grep "${ALIAS}.")"

        if [[ -z "${config}" ]]; then
            message_and_error "no_alias"
        fi

        _set_config_value "${config}" "app"
        _set_config_value "${config}" "key"
        _set_config_value "${config}" "dir"
    fi
}

command_help() {
    usage
}

command_usage() {
    usage
}

command_bump() {
    local sum=''

    sum="$(cat "${CURRENT_FILE_FULL}" | grep -vE "CHECKSUM='[[:lower:][:digit:]]{64}'" | shasum -a 256 | cut -d " " -f1)"

    if [[ "${sum}" != "${CHECKSUM}" ]]; then
        cp "${CURRENT_FILE_FULL}" "/tmp/${CURRENT_FILE}"
        sed -i -e "s/\(CHECKSUM='\)\([[:lower:][:digit:]]\{64\}\)'/\1${sum}'/" "/tmp/${CURRENT_FILE}"
        cp "/tmp/${CURRENT_FILE}" "${CURRENT_FILE_FULL}"
        message_and_exit "bump_bumped" "${sum}"
    else
        message_and_exit "bump_equal"
    fi
}

command_update() {
    local sum=''

    curl -qsLo "/tmp/${CURRENT_FILE}" "${SOURCE_URL}"
    
    if [[ "$?" -ne 0 ]]; then
        message_and_error "update_error"
    fi

    sum="$(shasum -a 256 "/tmp/${CURRENT_FILE}" | cut -d " " -f1)"

    if [[ "${CHECKSUM}" != "${sum}" ]] && [[ "$!" -eq 0 ]]; then
        cp "/tmp/${CURRENT_FILE}" "${CURRENT_FILE_FULL}"
        message_and_exit "update_updated"
    else
        message_and_exit "update_equal"
    fi
}

command_status() {
    output="$(ps ax | grep "${SSH_ENV_VAR}*" | grep -vE "grep|${CURRENT_FILE}")"
    if [[ -z "${output}" ]]; then
        message_and_exit "no_tunnel"
    fi
    
    output="$(echo ${output} | awk '{print "  [UP] APP: " $10 " PORT: " $15}' | sed -e "s/SendEnv=${SSH_ENV_VAR}//" | cut -d':' -f 1-3)"

    echo "${output}"
}

command_up() {
    local pid=''

    if [[ -S "$(get_sock_path)" && -f "$(get_ip_path)" ]]; then
        ssh -S "$(get_sock_path)" -O check ec2-user@"$(cat $(get_ip_path))" 1>/dev/null 2>/dev/null
    
        if [[ $? -eq 0  ]]; then
            message_and_exit "tunnel_running"
        fi
    fi

    if [[ -n "${DIR}" ]]; then
        DIR="$(echo ${DIR} | sed "s:~:${HOME}:")"
        if [[ ! -d "${DIR}" ]]; then
            message_and_error "no_dir"
        fi

        cd "${DIR}"
    fi

    EB_VARS="$(eb ssh ${APP} --number 1 --command 'echo "EC2_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)" && sudo docker exec  $(sudo docker ps -q) env;' | grep -E "RDS|EC2" | grep -v "INFO")"
 
    if [[ $? -ne 0 ]]; then
        message_and_error "eb_folder"
    fi
    
    RDS_HOSTNAME="$(echo "${EB_VARS}" | grep 'RDS_HOSTNAME' | sed 's/RDS_HOSTNAME=//')";
    RDS_PORT=$(echo "${EB_VARS}" | grep 'RDS_PORT' | sed 's/RDS_PORT=//');
    EC2_IP="$(echo "${EB_VARS}" | grep 'EC2_IP' | sed 's/EC2_IP=//')";

    ssh -M -S "$(get_sock_path)" -o "SendEnv=${SSH_ENV_VAR}${APP}" -i "~/.ssh/${KEY}.pem" -f -L ${PORT}:"${RDS_HOSTNAME}":${RDS_PORT} "${EC2_USER}"@"${EC2_IP}" -N 1>/dev/null 2>/dev/null

    if [[ $? -ne 0 ]]; then
        message_and_error "tunnel_error"
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
    load_config
    validate_parameters
    "command_${COMMAND}"
    _exit
}

main "$@"

