#--------------------------------------------------
# my_backup script that dumps SQLite databases
#--------------------------------------------------

# Check that this script has been sourced
[[ ${BASH_SOURCE[0]} == ${0} ]] && { echo "Error: This script should be sourced by 'my_backup.sh'!" >&2 ; exit -1; }

# Check required variables
[ -z "${SQLITE_DBS}" ] && { echo "Warning: SQLite backup skipped!"; return; }

# Set SQLITE_DIR and create if it does not exist
SQLITE_DIR="${MY_BACKUP_OUTPUT_DIR}/sqlite3"
[ -d "${SQLITE_DIR}" ] || mkdir "${SQLITE_DIR}"

# Dump databases
echo
echo "==  SQLITE3  =="
echo "Backing up data from ..."
for DB in ${SQLITE_DBS}; do
    DB_DIR=$(dirname ${DB})
    [ -d "${SQLITE_DIR}/${DB_DIR}" ] || mkdir -p "${SQLITE_DIR}/${DB_DIR}"
    echo "Backing up data from ${DB} in '${SQLITE_DIR}/'..."
    sqlite3 ${DB} .dump > "${SQLITE_DIR}/${DB}"
done

#/----------------------------------
# Restoring sqlite databases
# http://www.ibiblio.org/elemental/howto/sqlite-backup.html
#/----------------------------------
# Restoring the database from a backup is just as easy as backing
# up, except we must make sure the destination database is empty
# first. Alternatively you may want to delete or rename the
# destination database and let sqlite create a new one for you.
#  cd /home/sqlite
#  mv sample.db sample.db.old
#  sqlite3 sample.db < sample.bak
#-----------------------------------
