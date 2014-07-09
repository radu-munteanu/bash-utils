#!/bin/bash

MSG_ERR='ERROR:'
readonly MSG_WARN='WARNING:'
readonly MSG_INFO='INFO:'

readonly NOT_APPLICABLE="N/A"

function printx() {
  printf "$@" 2>&1 | tee -a "${LOG_FILE}"
}

function is_integer() {
  local exit_code=1
  
  if [ $# -ge 1 ]; then
    local param="${1}"
    grep --color=never -E -x -q '\-?[1-9]{1}[0-9]*' <<< "${param}" 1>/dev/null 2>/dev/null
    exit_code=$?
  fi
  return $exit_code
}

function is_valid_exit_code() {
  if [ $# -ge 1 ] && printf "%s" "$1" | grep --color=never -E -q "^[1-9][0-9]{0,2}$" && [ $1 -lt 256 ]; then
    return 0
  fi
  return 1
}

function get_formated_elapsed_time() {
  local formated_elapsed_time="${NOT_APPLICABLE}"
  if [ $# -ge 2 ]; then
    local time1="${1}"
    local time2="${2}"
    if is_integer "${time1}" && is_integer "${time2}"; then
      local elapsed_time_in_seconds=$(($time2-$time1))
      if [ $elapsed_time_in_seconds -lt 0 ]; then
        elapsed_time_in_seconds=$((0-$elapsed_time_in_seconds))
      fi
      formated_elapsed_time=$(printf "%d:%.2d:%.2d" $(($elapsed_time_in_seconds/3600)) $(($elapsed_time_in_seconds/60%60)) $(($elapsed_time_in_seconds%60)))
    fi
  fi
  
  printf "%s" "${formated_elapsed_time}"
}

function close() {
  local exit_code=0
  if [ $# -ne 0 ] && [ $1 -lt 256 ]; then
    exit_code=$1
  fi
  
  local end_time=$(date +%s)
  local elapsed_time="$(get_formated_elapsed_time $START_TIME $end_time)"
  
  printf ">> Time elapsed: %s.\n" "${elapsed_time}"
  
  exit $exit_code
}

function simple_close() {
  local exit_code=0
  if [ $# -ne 0 ] && [ $1 -lt 256 ]; then
    exit_code=$1
  fi
  rm -rf "${LOG_FILE}"
  local end_time=$(date +%s)
  local elapsed_time="$(get_formated_elapsed_time $START_TIME $end_time)"
  
  printf ">> Time elapsed: %s.\n" "${elapsed_time}"
  
  exit $exit_code
}

function print_help_command() {
  printf "%s\n" "${SCRIPT_HELP}"
}

function check_params_no() {
  if [ -z $PARAMS_NO ]; then
    printx "%s Number of parameters are not defined (PARAMS_NO is not set)!\n" "${MSG_ERR}"
    simple_close 1
  fi
  
  if [ $PARAMS_NO -eq 0 ]; then
    printx "%s Number of parameters < 1! Run '%s help' or '%s --help' for more help.\n" "${MSG_ERR}" "${SCRIPT_NAME}" "${SCRIPT_NAME}"
    simple_close 1
  fi
}