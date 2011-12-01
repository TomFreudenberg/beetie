#!/bin/bash

#
# This file is part of beetie (https://github.com/TomFreudenberg/beetie/wiki).
#
# Beetie is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# Created by 4commerce technologies AG (Tom Freudenberg)
# beetie.base (1.0.0)

# Description
#
# this is a codebase for all kind of scripting tools
#
# it defines a standard script template with option handling
# trap cleanup and internationalization possibilities. to
# create a new script please use beetie.tpl as a
# starting point to your development. you have to implement
# at lease all kind of my_... functions. please have a look.

#
# copyright: print out standard script header
#
__copyright() {
  # check quiet mode, if not empty quit function
  #
  [[ -z "${OPT_QUIET}" ]] || return 0

  # did we print this already
  [[ -z "${FLAG_CPRIGHT}" ]] || return 0

  echo ""
  echo ""
  echo "${CPRIGHT1}"
  echo "${CPRIGHT2}"
  echo "${CVERSION}"
  echo ""

  # always set flag to true
  # we won't have to check always for flag state here
  # because all time this is called only by __print
  # and there it will be checked
  FLAG_CPRIGHT="1"
}

#
# print: for all kind of output
#
__print() {
  #
  # $1 message text
  # $2 verbosity deepness, "" means print always
  #
  # check quiet mode, if not empty quit function
  [[ -z "${OPT_QUIET}" ]] || return 0

  # check copyright state, first time print it as header
  [[ -z "${FLAG_CPRIGHT}" ]] && __copyright

  # check verbosity level and print if fit
  [[ -z "${2}" || "${2}" == "${OPT_VERBOSE}" || "${2}" < "${OPT_VERBOSE}" ]] && echo "$1"
}

#
# help: first time called, it generate the help message and print it out
#
__help() {
  #
  # this uses a multiline help text

  # build if first time
  if [[ -z "${HELP_TEXT}" ]]
  then

  HELP_TEXT=$(TEXTDOMAIN="$TEXTDOMAIN_BASE" eval_gettext \
  \
  'usage:
  {MY_HELP_TEXT}
  -q|--quiet              do not print anything

  -v[v[v[v[v]]]]          level of verbosity

  --simulate              just calc all params and show command to run

  -?|--help               this help

  ')

  my_help; HELP_TEXT="${HELP_TEXT/\{MY_HELP_TEXT\}/$MY_HELP_TEXT}"

  fi

  # print out
  __print "${HELP_TEXT}"
}

#
# errormsg: set human readable messages for error codes
#
__errormsg() {
  #
  # $1 error code
  # set error message base on error code
  #
  case "${1}" in
    "${ERR_EXEC_ERROR}")
      ERR_MESSAGE="$(TEXTDOMAIN="$TEXTDOMAIN_BASE" eval_gettext 'execution fail.')"
      ;;
    "${ERR_INVALID_PATH}")
      ERR_MESSAGE="$(TEXTDOMAIN="$TEXTDOMAIN_BASE" eval_gettext 'invalid path.')"
      ;;
    "${ERR_INVALID_FILE}")
      ERR_MESSAGE="$(TEXTDOMAIN="$TEXTDOMAIN_BASE" eval_gettext 'invalid file.')"
      ;;
    "${ERR_INVALID_TEMP}")
      ERR_MESSAGE="$(TEXTDOMAIN="$TEXTDOMAIN_BASE" eval_gettext 'invalid temp file or path.')"
      ;;
    "${ERR_INVALID_LANG}")
      ERR_MESSAGE="$(TEXTDOMAIN="$TEXTDOMAIN_BASE" eval_gettext 'invalid language.')"
      ;;
    "${ERR_PRIV_NO_ROOT}")
      ERR_MESSAGE="$(TEXTDOMAIN="$TEXTDOMAIN_BASE" eval_gettext 'you need root privileges to run this.')"
      ;;
    "${ERR_PARAM_ERROR}")
      ERR_MESSAGE="$(TEXTDOMAIN="$TEXTDOMAIN_BASE" eval_gettext 'parameter settings error.')"
      ;;
    "${ERR_PARAM_ASSIGNED}")
      ERR_MESSAGE="$(TEXTDOMAIN="$TEXTDOMAIN_BASE" eval_gettext 'parameter was already assigned.')"
      ;;
    "${ERR_PARAM_MANDATORY}")
      ERR_MESSAGE="$(TEXTDOMAIN="$TEXTDOMAIN_BASE" eval_gettext 'mandatory parameter is missing.')"
      ;;
    "${ERR_PARAM_UNKNOWN}")
      ERR_MESSAGE="$(TEXTDOMAIN="$TEXTDOMAIN_BASE" eval_gettext 'unknown parameter.')"
      ;;
    "${ERR_PARAMS_MISSING}")
      ERR_MESSAGE="$(TEXTDOMAIN="$TEXTDOMAIN_BASE" eval_gettext 'no parameters were given.')"
      ;;
    "${ERR_NO_LOCALIZATION}")
      ERR_MESSAGE="$(TEXTDOMAIN="$TEXTDOMAIN_BASE" eval_gettext 'GNU gettext is not installed.')"
      ;;
    *)
      ERR_MESSAGE="$(TEXTDOMAIN="$TEXTDOMAIN_BASE" eval_gettext 'script aborted.')"
      ;;
  esac

  # call custom error handler
  my_errormsg "${1}"
}

#
# debug_var: set a trap DEBUG for variables to inspect
#            like : trap "__trap_var 'MY_VAR'" DEBUG
#            make sure, that you add a trap for each
#            local context you define your vars
#
__trap_var() {
  #
  # $1 name of var to inspect
  #
  for vars in "${@}"
  do
    echo "__trap_var: ${vars} = [${!vars}]"
  done
}

#
# abort: set an error text and abort running
#
__abort() {
  # get error message
  __errormsg "${1}"

  # print message
  __print "$(TEXTDOMAIN="$TEXTDOMAIN_BASE" eval_gettext 'ERROR! Abort:') ${ERR_MESSAGE} ${ERR_MESSAGE_INFO}(${1})"

  # exit with given code
  exit "${1}"
}

#
# exit: set additional information for abort message and exit with code
#
__exit() {
  #
  # $1 [opt] exit code, else 0
  # $2 [opt] additional status information
  # $3 [opt] line number with error statement
  #
  ERR_MESSAGE_INFO="${2}"
  ERR_MESSAGE_LINENO="${3}"

  exit "${1:-0}"
}

#
# sysinit: first time initialization, before anythings else is done
#          do not use it for long term processes like file opening
#          and so on, in that case you have to use initialize
#
ARGC="${#@}"
#
__sysinit() {
  #
  # [opt] $1 count params to check for minimum to run

  #
  # this is the primary initilization
  # please do not change anything here
  # all custom stuff should be in prepared
  # ..._custom() functions

  # global error codes
  # please use error codes:
  #    0 -  64 as default unspecified error
  #   65 -  95 reserved by framework errors
  #   96 - 255 good for custom errors
  #
  ERR_ERROR=65
  ERR_EXEC_ERROR=66
  ERR_INVALID_PATH=67
  ERR_INVALID_FILE=68
  ERR_INVALID_TEMP=69
  ERR_INVALID_LANG=70
  ERR_PRIV_NO_ROOT=75
  ERR_PARAM_ERROR=80
  ERR_PARAM_ASSIGNED=81
  ERR_PARAM_MANDATORY=82
  ERR_PARAM_UNKNOWN=83
  ERR_PARAMS_MISSING=84
  ERR_NO_LOCALIZATION=90
  ERR_CUSTOM_BASE=128

  # flag to handle print out from copyright
  FLAG_CPRIGHT=""

  # enabled internationalization GNU gettext
  export TEXTDOMAINDIR="/usr/share/beetie/locale"
  export TEXTDOMAIN="${CNSCRIPT}"
  . gettext.sh >/dev/null 2>&1 || __abort ${ERR_NO_LOCALIZATION}

  # set TEXTDOMAIN for this base script
  TEXTDOMAIN_BASE="beetie.base"

  # test for at least ? parameter
  (( ${1:-0} <= ${ARGC:-0} )) || __abort ${ERR_PARAMS_MISSING}

}

#
# initialize: setup everything you to run your script
#
__initialize() {
  #
  # init this script

  HELP_TEXT=""

  OPT_SIMULATE=""
  OPT_VERBOSE=""
  OPT_QUIET=""

  # attach cleaner trap
  for ((i=1; i<=64; i++))
  do
    trap "__cleanup '${i}'" ${i}
  done

  # attach EXIT trap
  trap   "__cleanup 'EXIT'" EXIT

  # initialize custom
  my_initialize
}

#
# cleanup: will be called always! when script should be exit
#          in every case you have the possibility to cleanup
#          your process safe
#
__cleanup() {
  #
  # $1 signal or EXIT for trap entry
  # in case of EXIT ${?} holds exit code

  # first of all we have to save the last process result id
  EXIT_CODE="${?}"

  # check that we use it or just ${1}
  [[ "${1}" == "EXIT" ]] || EXIT_CODE="${1}"

  # repair stty if it was use while initialize
  [[ -n "${OPT_INIT_STTY}" ]] && stty ${OPT_INIT_STTY}

  # cleanup custom
  my_cleanup "${EXIT_CODE}"

  # reset traps
  for ((i=1; i<=64; i++))
  do
    trap - ${i}
  done

  # reset exit trap
  trap - EXIT

  # exit with error message and previous exit code
  # check that it was not called with "no error"
  # as __cleanup 0
  [[ "${EXIT_CODE}" == "0" ]] || __abort "${EXIT_CODE}"

  # always at least exit and
  # if we are at this point no error was given
  exit 0
}

#
# get_options: interpret the command line options
#
__get_options() {
  #
  # test global parameter, if it is unknown we will
  # return code 0 (false) otherwise 1 (true/ok)
  #
  case "${1}" in

    "-v"|"-vv"|"-vvv"|"-vvvv"|"-vvvvv")
       OPT_VERBOSE="${1}"
       ;;

    "-q"|"--quiet")
       OPT_QUIET="${1}"
       ;;

    "--simulate")
       __print "$(TEXTDOMAIN="$TEXTDOMAIN_BASE" eval_gettext 'simulation mode is turned on...')"
       OPT_SIMULATE="echo [SIM] "
       ;;

    "--version")
       __print
       exit 0
       ;;

    "--help"|"-?")
       __help
       exit 0
       ;;

    *) return 1
       ;;

  esac

  return 0
}

#
# unescape_param: for strings like "word\ word" or "'word' 'word'"
#
__unescape_param() {
  #
  # $1 param name
  #
  eval ${1}="${!1}"
}

#
# abort_if_param_assigned: test and abort if param is not assigned
#
__abort_if_param_assigned() {
  #
  # $1 param name
  # $2 [opt] message
  # $3 [opt] exit code
  #
  [[ -n "${!1}" ]] && __exit ${3:-$ERR_PARAM_ASSIGNED} "[${2:-$1}]"
}

#
# abort_miss_mandatory_param: test and abort if mandatory is missing
#
__abort_if_miss_mandatory_param() {
  #
  # $1 param name
  # $2 [opt] message
  # $3 [opt] exit code
  #
  [[ -n "${!1}" ]] || __exit ${3:-$ERR_PARAM_MANDATORY} "[${2:-$1}]"
}

#
# abort_if_not_root_priv: test and abort if not root
#
__abort_if_not_root_priv() {
  #
  [[ "${UID}" == "0" ]] || __exit ${ERR_PRIV_NO_ROOT} "[${USER}]"
}

#
# warn_if_not_root_priv: test and warn only if not root
#
__warn_if_not_root_priv() {
  #
  [[ "${UID}" == "0" ]] || {
    __print "[${USER}] $(TEXTDOMAIN="$TEXTDOMAIN_BASE" eval_gettext 'you do not have root privileges.')"
  }
}

#
# test_param_eq_else_set_alt: test if param is equal to compare value otherwise set alternate
#
__test_param_eq_else_set_alt() {
  #
  # $1 param name
  # $2 [opt] compare value
  # $3 alternate value
  #
  [[ "${!1}" == "${2}" ]] && eval ${1}="${3}"
}

#
# test_param_ne_else_set_alt: test if param is unequal to compare value otherwise set alternate
#
__test_param_ne_else_set_alt() {
  #
  # $1 param name
  # $2 [opt] compare value
  # $3 alternate value
  #
  [[ "${!1}" != "${2}" ]] && eval ${1}="${3}"
}

