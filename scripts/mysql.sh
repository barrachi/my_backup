#--------------------------------------------------
# my_backup script that dumps MySQL databases
#--------------------------------------------------

# Check that this script has been sourced
[[ $_ != $0 ]] || echo "Error: This script should be sourced by 'my_backup.sh'!" >&2 || exit -1

# Check required variables
[ -z "${MYSQL_USER}" -o -z "${MYSQL_PASS}" ] && echo "Warning: MySQL backup skipped!" && return

# Set MYSQL_DIR and create if it does not exist
MYSQL_DIR="${MY_BACKUP_OUTPUT_DIR}/mysql"
[ -d "${MYSQL_DIR}" ] || mkdir "${MYSQL_DIR}"

# Dump databases
echo
echo "==  MySQL  =="
echo "Backing up data from MySQL in '${MYSQL_DIR}/'..."
echo
DBS=$( mysql -u ${MYSQL_USER} --password=${MYSQL_PASS} -e "show databases;" -B \
       | awk 'NR!=1 {print;}' \
       | grep -v information_schema \
       | grep -v performance_schema \
       | grep -v mysql )
for db in ${DBS};
do
    echo " Database ${db}..."
    mysqlhotcopy -u ${MYSQL_USER} -p ${MYSQL_PASS} --allowold ${db} ${MYSQL_DIR} >/dev/null;
done

#/----------------------------------
# Restoring mysql databases
# http://www.thegeekstuff.com/2008/07/backup-and-restore-mysql-database-using-mysqlhotcopy/
#\----------------------------------
# To restore the backup from the mysqlhotcopy backup, simply copy
# the files from the backup directory to the
# /var/lib/mysql/{db-name} directory. Just to be on the safe-side,
# make sure to stop the mysql before you restore (copy) the
# files. After you copy the files to the /var/lib/mysql/{db-name}
# start the mysql again.
#-----------------------------------
