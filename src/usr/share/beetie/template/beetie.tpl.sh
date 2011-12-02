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

CPRIGHT1="Please enter your authoring information"
CPRIGHT2="Allowed to use under the terms of the GNU LGPL"
CNSCRIPT="$(basename ${0})"
CVERSION="${CNSCRIPT} (1.0.0)"

#
# please comment your stuff here

# include beetie.base
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
  echo -e "\nWARNING! my_initialize: check options"
  # if you need more accurate time calculation or date logging
  # please move "OPT_INIT_TIME" to be first line in main loop
  #OPT_INIT_TIME="$(date +"%Y%m%d %H:%M:%S")"
  #OPT_INIT_PATH="$(builtin pwd)"
  #OPT_INIT_STTY="$(stty -g)"

  # please do not use __print inside this section
  # because the copyright info will be always printed
  # also in case that the caller has specified --quiet
  # because this is first tested in next part

  # just init your values here and if something is wrong
  # you can use "exit errorcode" to get a full message
  # if you wish to add some additional informationen
  # for this just set the value of ERR_MESSAGE_INFO
  # before using exit

  # local error codes
  # please use error codes:
  #    0 -  64 as default unspecified error
  #   65 -  95 reserved by framework errors
  #   96 - 255 good for custom errors
  #
  # let ERR_MY_ERROR="${ERR_CUSTOM_BASE}+0"

  # initialize local parameter
  # please place your code here

}

my_cleanup() {
  #
  # $1 exit code for trap entry
  #
  # please place your code here

  __print "$(eval_gettext 'inside my_cleanup')"
  __print "$(printf "$(eval_gettext 'script has taken %d second(s) time!')" ${SECONDS})"
}

my_get_options() {
  #
  # get parameter from command line options
  #
  while [[ -n "${1}" ]]
  do
    case "${1}" in

      # insert your options here

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

my_main() {
  #
  # please place your code here
  #
  __copyright

  $OPT_SIMULATE \
  __print "$(printf "$(eval_gettext 'inside my_main from %s.')" ${CNSCRIPT})"

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

