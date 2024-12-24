#!/bin/bash
echo "[ENTRYPOINT] Starting Server Confdiguration"

# Set Wine environment variables
export WINEARCH=win64
export WINEPREFIX=/serverdata/wine64
export WINEDEBUG="-all"

# Copy configuration if available
if [ -d "${CONFIG_DIR}" ] && [ "$(ls -A ${CONFIG_DIR})" ]; then
  echo "[ENTRYPOINT] Copying configuration files"
  cp -R "${CONFIG_DIR}/" "${SERVER_DIR}/"
fi

# Ensure WINE64 directory exists
echo "[ENTRYPOINT] Checking if WINE workdirectory is present"
if [ ! -d "${WINEPREFIX}" ]; then
   echo "[ENTRYPOINT] WINE workdirectory not found, creating please wait..."
   mkdir -p "${WINEPREFIX}"
else
  echo "[ENTRYPOINT] WINE workdirectory found"
fi

# Ensure WINE is properly installed
echo "[ENTRYPOINT] Checking if WINE is properly installed"
if [ ! -d "${WINEPREFIX}/drive_c/windows" ]; then
  echo "[ENTRYPOINT] Setting up WINE"
  winecfg > /dev/null 2>&1
else
  echo "[ENTRYPOINT] WINE properly set up"
fi

# Ensure server directory exists
cd "${SERVER_DIR}/TT2/Binaries/Win64" || {
  echo "[ENTRYPOINT] Directory not found: ${SERVER_DIR}/TT2/Binaries/Win64"
  echo "[ENTRYPOINT] Putting container into sleep mode for debugging. If you see this message, please check the README for instructions or open an issue on GitHub!"
  sleep infinity
}

# Start the server
if [ -f "TT2Server-Win64-Shipping.exe" ]; then
  exec wine64 TT2Server-Win64-Shipping.exe & TT2_PID=$! ; tail -c0 -F ${SERVER_DIR}/TT2/Saved/Logs/TT2.log --pid=$TT2_PID
else
  echo "[ENTRYPOINT] Something went wrong, can't find the executable, putting container into sleep mode!"
  sleep infinity
fi
