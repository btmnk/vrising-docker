#!/bin/bash

set -euo pipefail

# -------------------------------
# CONFIGURATION
# -------------------------------

# load .env file
if [ -f .env ]; then
    set -o allexport
    source .env
    set +o allexport
    echo "[INFO] .env loaded."
else
    echo ".env file missing. Run cp .env.example .env"
    exit 1
fi

# Defaults (when .env vars are missing)
data_dir="${DATA_DIR:-./data}"
backup_dir="${BACKUP_DIR:-./backups}"
max_backups="${MAX_BACKUPS:-5}"
backup_date_format="${BACKUP_DATE_FORMAT:-%Y-%m-%d_%H-%M-%S}"
backup_prefix="${BACKUP_PREFIX:-data-backup}"

timestamp=$(date +"$backup_date_format")
backup_filename="${backup_prefix}_${timestamp}.zip"
log_file="${BACKUP_LOG_FILE:-./backup.log}"

# -------------------------------
# FUNCTIONS
# -------------------------------

log() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] $*" | tee -a "$log_file"
}

# -------------------------------
# BACKUP
# -------------------------------

log "Backup starting..."

# make sure directories exist
mkdir -p "$data_dir" "$backup_dir"

# create backup
zip -r "$backup_dir/$backup_filename" "$data_dir" >> "$log_file" 2>&1
log "Backup $backup_filename created."

# collect existing backup files
shopt -s nullglob
backup_files=(${backup_dir}/${backup_prefix}_*.zip)
backup_count="${#backup_files[@]}"
log "Existing backups: $backup_count"

# delete old backups
if [ "$backup_count" -gt "$max_backups" ]; then
    delete_count=$(( backup_count - max_backups ))
    log "Deleting backups: $delete_count"

    ls -1tr ${backup_dir}/${backup_prefix}_*.zip | head -n "$delete_count" | while read -r file; do
        rm -f -- "$file"
        log "Backup deleted: $file"
    done
else
    log "No old backups to delete."
fi

log "Backup done."
