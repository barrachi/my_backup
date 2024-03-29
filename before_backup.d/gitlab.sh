#--------------------------------------------------
# my_backup script that dumps GitLab data
#--------------------------------------------------

# Check that this script has been sourced
[[ ${BASH_SOURCE[0]} == ${0} ]] && { echo "Error: This script should be sourced by 'my_backup.sh'!" >&2 ; exit -1; }

# Write banner
echo
echo "==  GitLab  =="

# Check required variables
[ -z "${GITLAB_CONTAINER_NAME}" -o -z "${GITLAB_SRV_DIR}" ] && { echo "Warning: GitLab backup skipped!"; return; }

# Get backup name
BACKUP_NAME=$(docker exec gitlab grep gitlab-ce /opt/gitlab/version-manifest.txt | replace " " "-")
[ -z "${BACKUP_NAME}" ] && BACKUP_NAME=$(docker exec gitlab grep gitlab-ee /opt/gitlab/version-manifest.txt | replace " " "-")
[ -z "${BACKUP_NAME}" ] && BACKUP_NAME="gitlab-unknown"

# Dump GitLab data
echo "Backing up data from GitLab in '${GITLAB_SRV_DIR}/data/backups/'..."
echo
docker exec -t ${GITLAB_CONTAINER_NAME} gitlab-backup create STRATEGY=copy BACKUP=${BACKUP_NAME} GZIP_RSYNCABLE=yes

#/----------------------------------
# Restoring the gitlab backup
# https://docs.gitlab.com/ee/raketasks/backup_restore.html
#\----------------------------------
