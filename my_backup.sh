#!/usr/bin/env bash

###########################################################################
#  my_backup.sh -- A simple backup script for a Gentoo systemd system     #
#                                                                         #
#  Copyright 2017-8 Sergio Barrachina Mir <barrachi@uji.es>               #
#                                                                         #
#  This program is free software: you can redistribute it and/or modify   #
#  it under the terms of the GNU General Public License as published by   #
#  the Free Software Foundation; either version 3 of the License, or      #
#  (at your option) any later version.                                    #
#                                                                         #
#  This program is distributed in the hope that it will be useful, but    #
#  WITHOUT ANY WARRANTY; without even the implied warranty of             #
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU      #
#  General Public License for more details.                               #
#                                                                         #
#  You should have received a copy of the GNU General Public License      #
#  along with this program.  If not, see <http://www.gnu.org/licenses/>   #
#                                                                         #
###########################################################################

# Set SCRIPTPATH to my location
pushd $(dirname $BASH_SOURCE[0]) > /dev/null
SCRIPTPATH="$( pwd -P )"
popd > /dev/null

# Usage
usage() { echo "Usage: $0 [-c CONFIG] -- [BORG_CREATE_ARGS]" 1>&2; exit 1; }

# Get options
while getopts ":c:" o; do
  case "${o}" in
    c)
      CONFIG=${OPTARG}
      ;;
    *)
      usage
      ;;
    esac
done
shift $((OPTIND-1))

BORG_CREATE_ARGS=${*}

# Source configuration
CONFIG="${CONFIG:-${HOME}/.config/my_backup/default.conf}"
[ -f "${CONFIG}" ] || { echo "Error: configuration file '${CONFIG}' not found!" >&2 ; exit -1; }
source ${CONFIG}

# Check required variables
[ -z "${MY_BACKUP_OUTPUT_DIR}" ] && { echo "Error: my_backup.sh is not properly configured (MY_BACKUP_OUTPUT_DIR is not defined)!" ; exit -1; }

# Create MY_BACKUP_OUTPUT_DIR if it does not exist
[ -d "${MY_BACKUP_OUTPUT_DIR}" ] || mkdir -p "${MY_BACKUP_OUTPUT_DIR}"

# Launch before backup scripts
echo "******************************************************************************"
echo "** before backup scripts"
echo "******************************************************************************"
for f in ${SCRIPTPATH}/before_backup.d/*.sh; do
  source "${f}"
done

# Check required variables for borg backup command
for VAR in BORG_REPOSITORIES BORG_PASSPHRASE BORG_ARCHIVE_PREFIX BACKUP_PATHS; do
    [ -z "${!VAR}" ] && { echo "Error: required variable '${VAR}' is not defined!"; exit -1; }
done

# Set EXCLUDE_FROM_OPTION
EXCLUDE_FROM_OPTION=""
[ -f "${EXCLUDED_FILES_FILE}" ] &&  EXCLUDE_FROM_OPTION="--exclude-from ${EXCLUDED_FILES_FILE}"

for BORG_REPO in ${BORG_REPOSITORIES}; do
  echo
  echo "******************************************************************************"
  echo "** borg backup create on '${BORG_REPO}'"
  echo "******************************************************************************"
  # Export borg required variables
  export BORG_REPO
  export BORG_PASSPHRASE
  # Launch borg init if the repository does not exist
  [ -z "$(borg info :: 2>&1 | grep 'does not exist.')" ] \
      || { borg init --encryption=repokey-blake2 :: || exit -1 ; }
  # Increase the time to live for the files caches entries from 20 to 60 ( > 24*2 + 2 )
  export BORG_FILES_CACHE_TTL=60
  # Launch borg create
  borg create --verbose --stats                                   \
              --exclude-if-present .nobackup --keep-exclude-tags  \
              --exclude-caches ${EXCLUDE_FROM_OPTION}             \
              --one-file-system                                   \
              --compression lz4                                   \
              ${BORG_CREATE_ARGS}                                 \
              ::"${BORG_ARCHIVE_PREFIX}_{now:%Y-%m-%d_%H:%M:%S}"  \
              ${BACKUP_PATHS} || exit -1

  echo
  echo "******************************************************************************"
  echo "** borg backup prune on '${BORG_REPO}'"
  echo "******************************************************************************"
  # Launch borg prune
  borg prune --verbose --stats --list --save-space                \
             --glob-archives="${BORG_ARCHIVE_PREFIX}*"            \
             --keep-hourly=10 --keep-daily=7 --keep-weekly=4      \
             --keep-monthly=6 --keep-yearly=2 :: || exit -1

  ## Check last archive
  ## borg check --glob-archives="${BORG_ARCHIVE_PREFIX}*" --last 1 ::
done

# Clear PageCache, dentries and inodes
#sync
#echo 3 > /proc/sys/vm/drop_caches
