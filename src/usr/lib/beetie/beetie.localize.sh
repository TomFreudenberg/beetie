#!/bin/bash
#

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

CPRIGHT1="Created by 4commerce technologies AG (Tom Freudenberg)"
CPRIGHT2="Allowed to use under the terms of the GNU LGPL"
CNSCRIPT="$(basename ${0})"
CVERSION="${CNSCRIPT} (1.0.0)"

#
# This is an utility to make easy for you to handle with your
# localization of your scripts. It controls xgettext and
# msgfmt

# include beetie.base.sh
. /usr/lib/beetie/beetie.base.sh

#
# just let the help be part of documentation in the beginning
# of the source code
#
my_help() {
  #
  # just set your helptext here
  #
  # if a.) you need special chars, b.) you have to write a lot and/or
  # c.) will translate help then you should place your help to the
  # external language resource also for the base language.
  #
  MY_HELP_TEXT=$(eval_gettext '
  here you get more help
  ')

}

my_errormsg() {
  #
  # $1 error code
  # set your own ERR_MESSAGE and ERR_MESSAGE_INFO here
  # based on what error where signaled

  case "${1}" in
  #  "${MY_ERROR_CODE}")
  #    ERR_MESSAGE="$(eval_gettext 'my error text.')"
  #    ;;

    *) # nothing to do
       ;;
  esac
}

my_initialize() {
  #
  # please enable what options will fit your needs

  # if you need more accurate time calculation or date logging
  # please move "OPT_INIT_TIME" to be first line in main loop
  #OPT_INIT_TIME="`date +%Y%m%d %H:%M:%S`"
  #OPT_INIT_PATH="`builtin pwd`"
  #OPT_INIT_STTY=`stty -g`

  # please do not use __print inside this section
  # because the copyright info will be always printed
  # also in case that the caller has specified --quiet
  # because this is first tested in next part

  # just init your values here and if something is wrong
  # you can use "exit errorcode" to get a full message
  # if you wish to add some additional informationen
  # for this just set the value of ERR_MESSAGE_INFO
  # before using exit

  # initialize local parameter
  LOCALIZE_BASE="/usr/share/beetie/locale"
  LOCALIZE_ACTION=""
  LOCALIZE_FILE=""
  LOCALIZE_LANG=""
  LOCALIZE_CLEAN=""
  LOCALIZE_HEADER=""

}

my_cleanup() {
  #
  # $1 exit code for trap entry
  #
  # please place your code here

  __print "$(printf "$(eval_gettext 'script has taken %d second(s) time!')" ${SECONDS})"
}

my_get_options() {
  #
  # get parameter from command line options
  #
  while [[ -n "${1}" ]]
  do
    case "${1}" in

      "--po"|"--mo")
         #
         __abort_if_param_assigned "LOCALIZE_ACTION" "--po|--mo"

         LOCALIZE_ACTION="${1}"

         [[ -z "${2}" || "${2:0:1}" == "-" ]] && __exit ${ERR_INVALID_FILE} "[${2:-?}]"

         LOCALIZE_FILE="$( which "${2}" )"
         [[ -f "${LOCALIZE_FILE}" ]] || __exit ${ERR_INVALID_FILE} "[${LOCALIZE_FILE:-2}]"

         shift
         ;;

      "--lang")
         #
         __abort_if_param_assigned "LOCALIZE_LANG" "${1}"
         __abort_if_miss_mandatory_param "LOCALIZE_ACTION" "--po|--mo"

         [[ "${#2}" == "2" && "${2:0:1}" != "-" ]] || __exit ${ERR_INVALID_LANG} "[${2:-?}]"

         [[ -d "${LOCALIZE_BASE}/${2}/LC_MESSAGES" ]] || __exit ${ERR_INVALID_LANG} "$(printf "$(eval_gettext 'locale path %s not exists.')" "${LOCALIZE_BASE}/${2}/LC_MESSAGES" )"

         LOCALIZE_LANG="${2}"

         shift
         ;;

      "--clean"|"--update-header")
         #
         __abort_if_param_assigned "LOCALIZE_CLEAN" "--clean|--update-header"
         __abort_if_param_assigned "LOCALIZE_HEADER" "--clean|--update-header"
         __abort_if_miss_mandatory_param "LOCALIZE_ACTION" "--po|--mo"

         [[ "${LOCALIZE_ACTION}" == "--po" ]] || __exit ${ERR_PARAM_ERROR} "$(printf "$(eval_gettext '%s only available with option %s.')" "${1}" "--po" )"

         case "${1}" in
           "--clean")         LOCALIZE_CLEAN="true";;
           "--update-header") LOCALIZE_HEADER="true";;
         esac
         ;;

      *)
         # check that there are only allowed params

         # look for param in global __get_option
         # if ok, then nothing else otherwise code block
         __get_options "${1}" || {

           # otherwise error
           __exit ${ERR_PARAM_UNKNOWN} "[${1}]"

         }
         ;;

    esac

    shift
  done
}

make_po_file() {
  local XGETTEXT=""
  local PO_FILE="${LOCALIZE_BASE}/${LOCALIZE_LANG}/LC_MESSAGES/${LOCALIZE_FILE##*/}.po"
  local FIX_PO_FILE_CHARSET=""

  # GNU gettext
  XGETTEXT="xgettext --lang=Shell"

  # check options
  [[ -f "${PO_FILE}" && -z "${LOCALIZE_CLEAN}" ]] && XGETTEXT="${XGETTEXT} -j"
  [[ -f "${PO_FILE}" && -z "${LOCALIZE_HEADER}" && -z "${LOCALIZE_CLEAN}" ]] && XGETTEXT="${XGETTEXT} --omit-header"

  # check option for charset
  [[ ! -f "${PO_FILE}" || -n "${LOCALIZE_CLEAN}" || -n "${LOCALIZE_HEADER}" ]] && FIX_PO_FILE_CHARSET="true"

  # append file for action
  XGETTEXT="${XGETTEXT} -o \"${PO_FILE}\" \"${LOCALIZE_FILE}\""

  # do it
  $OPT_SIMULATE \
    eval "${XGETTEXT}" || __exit "${?}"

  __print "ok: ${PO_FILE}"

  if [[ -n "${FIX_PO_FILE_CHARSET}" ]]
  then
    # input
    local PO_FILE_CONTENT="$(cat ${PO_FILE})"

    # search for content-type CHARSET
    if [[ "${PO_FILE_CONTENT}" =~ '(.*"Content-Type: text/plain; charset=)([^\]*)(\\n".*)' ]]
    then

      if (( "${BASH_REMATCH[2]}" == "CHARSET" ))
      then
        # replace with UTF-8
        PO_FILE_CONTENT="${BASH_REMATCH[1]}UTF-8${BASH_REMATCH[3]}"

        # write back to file
        $OPT_SIMULATE \
          echo "${PO_FILE_CONTENT}" > "${PO_FILE}" || __exit "${?}"

        __print "charset update: UTF-8"

      else

        __print "charset set: ${BASH_REMATCH[2]}"

      fi

    fi
  fi

}

make_mo_file() {
  local MSGFMT=""
  local PO_FILE="${LOCALIZE_BASE}/${LOCALIZE_LANG}/LC_MESSAGES/${LOCALIZE_FILE##*/}.po"
  local MO_FILE="${LOCALIZE_BASE}/${LOCALIZE_LANG}/LC_MESSAGES/${LOCALIZE_FILE##*/}.mo"

  # GNU gettext
  MSGFMT="msgfmt"

  # append file for action
  MSGFMT="${MSGFMT} -o \"${MO_FILE}\" \"${PO_FILE}\""

  # do it
  $OPT_SIMULATE \
   eval "${MSGFMT}" || __exit "${?}"

  __print "ok: ${MO_FILE}"

}

my_main() {
  #
  __copyright

  __abort_if_miss_mandatory_param "LOCALIZE_LANG" "--lang"

  case "${LOCALIZE_ACTION}" in

    "--po") make_po_file;;
    "--mo") make_mo_file;;

  esac

  __print
}

# ########################################################################
#
# void main
#

# basic initialization
__sysinit "1"

# init the local things
__initialize

# get all from command line
my_get_options "${@}"

# run custom main
my_main

# now cleanup everything and exit 0
__cleanup 0

