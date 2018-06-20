#----------------------------------------------------
# my_backup script that generates excluded files file
#----------------------------------------------------

# Check that this script has been sourced
[[ ${BASH_SOURCE[0]} == ${0} ]] && { echo "Error: This script should be sourced by 'my_backup.sh'!" >&2 ; exit -1; }

# Write banner
echo
echo "==  Excluded files  =="

# Check required variables
[ -z "${EXCLUDED_FILES_FILE}" ] && { echo "Warning: generation of EXCLUDED_FILES_FILE skipped!"; return; }

# Generate excluded_files file
echo "Creating '${EXCLUDED_FILES_FILE}' with files to be excluded..."
cat > ${EXCLUDED_FILES_FILE} <<EOF
#
# DO NOT EDIT THIS FILE!
#
# It has been generated by my_backup/scripts/excluded_files.sh script
#
#---------------------------------------------------
# Files and directories not to be backed up
#---------------------------------------------------

# XSession files
#------------------------------
/*/.xauth*
/*/.xsession-*

# Cache dirs
#------------------------------
/home/*/.cache

# Indexers and trash folders
#------------------------------
/*/.local/share/akonadi
/*/.local/share/baloo
/*/.local/share/Trash
/*/files_trashbin

# Download folders
#------------------------------
/*/Downloads
/*/Descargas

# Thumbnails folders
#------------------------------
/*/.thumbnails

# Wine folders
#------------------------------
/*/.wine

# Backup files
#------------------------------
*~
*.bak

# Version control dirs in homes
#------------------------------
/home/*/.git
/home/*/.bzr

EOF

if [ -d /home/chroot/home/ ]; then
    echo "#--------------------------------------------------" >> ${EXCLUDED_FILES_FILE}
    echo "# Chroot homes                                     " >> ${EXCLUDED_FILES_FILE}
    echo "#--------------------------------------------------" >> ${EXCLUDED_FILES_FILE}
    for HOME in /home/chroot/home/*;
    do
      echo "${HOME}" >> ${EXCLUDED_FILES_FILE}
    done
fi
