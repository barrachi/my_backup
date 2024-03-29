#--------------------------------------------------
# my_backup script that dumps PostgreSQL databases
#--------------------------------------------------

# Check that this script has been sourced
[[ ${BASH_SOURCE[0]} == ${0} ]] && { echo "Error: This script should be sourced by 'my_backup.sh'!" >&2 ; exit -1; }

# Write banner
echo
echo "==  POSTGRESQL  =="

# Check required variables
[ -z "${PGSQL_VER}" -o -z "${PGSQL_USER}" ] && { echo "Warning: PostgreSQL backup skipped!"; return; }

# Set PGSQL_DIR and create if it does not exist
PGSQL_DIR="${MY_BACKUP_OUTPUT_DIR}/pgsql/${PGSQL_VER}"
[ -d "${PGSQL_DIR}" ] || mkdir -p "${PGSQL_DIR}"
[ -d "${PGSQL_DIR}/data" ] || mkdir -p "${PGSQL_DIR}/data"

# Dump databases
echo "Backing up data from PostgreSQL ${PGSQL_VER} in '${PGSQL_DIR}/'..."
sudo -u  ${PGSQL_USER} /usr/bin/pg_dumpall | gzip > "${PGSQL_DIR}/pg_dumpall.out.gz"
PGSQL_SYSTEM_DIR=/etc/postgresql-${PGSQL_VER}  # Gentoo
[ -d "${PGSQL_SYSTEM_DIR}" ] || PGSQL_SYSTEM_DIR=/etc/postgresql/${PGSQL_VER}/main  # Ubuntu
for f in pg_hba.conf pg_ident.conf postgresql.conf;
do
  cp ${PGSQL_SYSTEM_DIR}/${f} ${PGSQL_DIR}/data/${f}
done

#/-----------------------------------
# How to restore postgresql databases
#\-----------------------------------
#  systemctl stop postgresql-x.y
#  ps -u postgres
#  del -rf /var/lib/postgresql
#  edit /etc/conf.d/postgresql-x.y
#  emerge --config =postgresql-x.y.z
#  systemctl start postgresql-x.y
#  psql -U ${PGSQL_USER} -f ${MY_BACKUP_OUTPUT_DIR}/pgsql/${PGSQL_VER}/pg_dumpall.out template1
#-------------------------------
