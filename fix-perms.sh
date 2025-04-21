#!/bin/bash
echo "[PERMISSIONS] Fixing permissions for mounted volumes..."

TARGET_UID=${TARGET_UID:-1000}
TARGET_GID=${TARGET_GID:-1000}

WINEPREFIX_PATH=/data/wine64
SAVED_PATH=/data/serverfiles/TT2/Saved
SERVER_FILES_PATH=/data/serverfiles 
CONFIG_SOURCE_PATH=/config_source/dedicated_server_config.json 
CONFIG_DEST_PATH="${SERVER_FILES_PATH}/dedicated_server_config.json"

echo "[PERMISSIONS] Target UID: ${TARGET_UID}, Target GID: ${TARGET_GID}"

mkdir -p "${WINEPREFIX_PATH}"
mkdir -p "${SAVED_PATH}"

# Fix permissions on the main volume mount points
echo "[PERMISSIONS] Chowning ${WINEPREFIX_PATH}"
chown -R "${TARGET_UID}:${TARGET_GID}" "${WINEPREFIX_PATH}"
echo "[PERMISSIONS] Chowning ${SAVED_PATH}"
chown -R "${TARGET_UID}:${TARGET_GID}" "${SAVED_PATH}"


# Copy config and fix its permissions if source exists
if [ -f "${CONFIG_SOURCE_PATH}" ]; then
  echo "[PERMISSIONS] Copying config from ${CONFIG_SOURCE_PATH} to ${CONFIG_DEST_PATH}"
  # Copy the file
  cp -f "${CONFIG_SOURCE_PATH}" "${CONFIG_DEST_PATH}"
  echo "[PERMISSIONS] Chowning ${CONFIG_DEST_PATH}"
  # Set ownership on the copied file
  chown "${TARGET_UID}:${TARGET_GID}" "${CONFIG_DEST_PATH}"
else
  echo "[PERMISSIONS] No config file found at ${CONFIG_SOURCE_PATH}, skipping copy."
fi

echo "[PERMISSIONS] Permissions fix complete."
exit 0
