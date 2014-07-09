#!/bin/bash

cd "$(dirname "$0")"

## Global Variables

MSG_ERR='ERROR:'

readonly START_DATE=$(date)
readonly START_TIME=$(date -d "${START_DATE}" +%s)
readonly RUN_HASH=$(uuidgen -r | cut -d- -f1)

readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
readonly SCRIPT_ORIGINAL_NAME="Sample Script"
readonly SCRIPT_VERSION="1.0"

readonly SCRIPT_HELP="$SCRIPT_ORIGINAL_NAME v.$SCRIPT_VERSION
  A sample script that can be used as template for other scripts.

  Usage: $SCRIPT_NAME <command>
    Commands:
      help | --help
        Shows this help.
      print <text>
        Prints the text given as parameter.

  Examples:
    $SCRIPT_NAME test"

PARAMS=( "$@" )
PARAMS_NO=$#

readonly LOG_FILE_PREFIX='template_script'
readonly LOG_FILE_EXT='log'
readonly LOG_FILE="${LOG_FILE_PREFIX}_$(date -d "${START_DATE}" +%Y-%m-%d_%H-%M-%S)_${RUN_HASH}.${LOG_FILE_EXT}"

printf ">> %s" "${SCRIPT_NAME}";for (( i=0;i<$PARAMS_NO;i++ )); do printf " \"%s\"" "${PARAMS[$i]}"; done; printf "\n"

## Script files import - error code: 255

function import() {

	# Import begin

  # Multiple import example:
	# source "${SCRIPT_DIR}/commons.sh" 2>&1 && source "${SCRIPT_DIR}/lib.sh" 2>&1
  
	source "${SCRIPT_DIR}/commons.sh" 2>&1

	# Import end

	local exit_code=$?

	if [ $exit_code -ne 0 ]; then
		local error_message="$MSG_ERR: Importing script functions failed!
  Exit code: $exit_code
  Output: any error output should be above above."
		printf "%s\n" "$error_message"
		exit 255
	fi
}

import

## Overwriting close function (from commons.sh)
function close() {
  local exit_code=0
  if [ $# -ne 0 ] && [ $1 -lt 256 ]; then
    exit_code=$1
  fi
  
  # Post-run actions - start - move log, remove temp files, send mail, etc.
  mv "${LOG_FILE}" '/tmp/'
  # Post-run actions - end
  
  local end_time=$(date +%s)
  local elapsed_time="$(get_formated_elapsed_time $START_TIME $end_time)"
  
  printf ">> Time elapsed: %s.\n" "${elapsed_time}"
  
  exit $exit_code
}

## Internal Functions - error code: 101
function print_text() {
  local text="${1}"
  local exit_code
  
  printx "%s\n" "${text}"
  exit_code=$?
  
  if [ $exit_code -eq 0 ]; then
    printx "%s %s\n" "${MSG_INFO}" "Print executed successfully."
  else
    printx "%s %s\n" "${MSG_ERR}" "Print failed!"
  fi
  
  close $exit_code
}

## Commands Functions - error code: 11-99
function print_command() {
  if [ $PARAMS_NO -lt 2 ]; then
    printx "%s Command 'print' requires at least one parameter! Run '%s help' or '%s --help' for more help.\n" "${MSG_ERR}" "${SCRIPT_NAME}" "${SCRIPT_NAME}"
    simple_close 11
  fi

  local text="${PARAMS[1]}"
  
  # 'Backend'
  print_text "${text}"
}


## Commands Run - exit code: 2

function run_commands() {
  case "${PARAMS[0]}" in
    "help"|"--help")
      print_help_command
      ;;
    "print")
      print_command
      ;;
    *)
      printx "%s Command not recognized! Run '%s help' or '%s --help' for more help.\n" "${MSG_ERR}" "${SCRIPT_NAME}" "${SCRIPT_NAME}"
      simple_close 2
  esac
}

## Main

check_params_no

run_commands

simple_close 0