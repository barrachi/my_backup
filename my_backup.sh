#!/bin/sh

###########################################################################
#  my_backup.sh -- A simple backup script for a Gentoo systemd system     #
#                                                                         #
#  Copyright 2017 Sergio Barrachina Mir <barrachi@uji.es>                 #
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
usage() { echo "Usage: $0 [-c CONFIG]" 1>&2; exit 1; }

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

# Source configuration
CONFIG="${CONFIG:-${SCRIPTPATH}/my_backup.conf}"
[ -f "${CONFIG}" ] || echo "Error: configuration file '${CONFIG}' not found!" >&2 && exit -1
source "${CONFIG}"

# Check required variables
[ -z "${MY_BACKUP_OUTPUT_DIR}" ] && echo "Error: my_backup.sh is not properly configured (MY_BACKUP_OUTPUT_DIR is not defined)!" && exit -1

# Create MY_BACKUP_OUTPUT_DIR if it does not exist
[ -d "${MY_BACKUP_OUTPUT_DIR}" ] || mkdir -p "${MY_BACKUP_OUTPUT_DIR}"

# Launch my_backup scripts
echo "*********************************"
echo "** Launching my_backup scripts **"
echo "*********************************"
for f in ${SCRIPTPATH}/scripts/*.sh; do
  source "${f}"
done

echo
echo "*********************************"
echo "**    Launching borg backup    **"
echo "*********************************"
# Check required variables for borg backup command
for VAR in BORG_REPO BORG_ARCHIVE BORG_PASSPHRASE BACKUP_PATHS EXCLUDED_FILES_FILE; do
    [ -z "${!VAR}" ]  && echo "Error: required variable '${VAR}' is not defined!" && exit -1
done
# Set EXCLUDE_FROM option
EXCLUDE_FROM=""
[ -z "${EXCLUDED_FILES_FILE}" ] || EXCLUDE_FROM="--exclude-from ${EXCLUDED_FILES_FILE}"
# Export borg required variables
export BORG_REPO
export BORG_PASSPHRASE
# Launch borg backup
borg create --verbose --stats --progress --exclude-if-present .nobackup --exclude-caches ${EXCLUDE_FROM} --compression lz4 ::${BORG_ARCHIVE} ${BACKUP_PATHS}
## Check last archive
## borg check --prefix {fqdn} --last 1 ::
