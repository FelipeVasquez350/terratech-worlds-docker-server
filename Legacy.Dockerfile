# =========================
# Stage 1: Builder
# =========================
FROM ubuntu:22.04 AS builder

# Set non-interactive mode for Debian frontend
ENV DEBIAN_FRONTEND=noninteractive

ARG BETA=false
ENV BETA=${BETA}

# Accept Steam license
RUN echo steam steam/question select "I AGREE" | debconf-set-selections && \
  echo steam steam/license note '' | debconf-set-selections

# Add i386 architecture and update package lists
RUN dpkg --add-architecture i386 && \
  apt-get update && \
  apt-get install -y \
  steamcmd \
  ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV TERRATECHDIR=/terratech-worlds

# Create necessary directories
RUN mkdir -p $TERRATECHDIR

# Symlink SteamCMD for easier access
RUN ln -s /usr/games/steamcmd /usr/bin/steamcmd

# Install Terratech Server using SteamCMD
RUN echo "Installing Terratech LEGACY..."; \
  steamcmd +@sSteamCmdForcePlatformType windows \
  +force_install_dir "$TERRATECHDIR" \
  +login anonymous \
  +app_update 2533070 --beta legacy_0.5_build validate \
  +quit

# =========================
# Stage 2: Runtime
# =========================
FROM debian:bookworm-slim AS runtime

# Environment variables
ENV DATA_DIR="/serverdata"
ENV SERVER_DIR="${DATA_DIR}/serverfiles"
ENV CONFIG_DIR="${DATA_DIR}/config"
ENV WINE_PREFIX="${DATA_DIR}/wine64"
ENV UMASK=0022
ENV UID=1000
ENV GID=1000
ENV USER="terratech"
ENV DATA_PERM=755

WORKDIR /serverdata

# Install dependencies
RUN dpkg --add-architecture i386 && \
  apt-get update && \
  apt-get install -y \
  wget \
  ca-certificates \
  gnupg2 \
  software-properties-common \
  lib32gcc-s1 \
  winbind \
  xvfb \
  screen \
  && rm -rf /var/lib/apt/lists/*

# Add WINE repository and install
RUN wget -qO - https://dl.winehq.org/wine-builds/winehq.key | apt-key add - && \
  echo "deb https://dl.winehq.org/wine-builds/debian/ bookworm main" > /etc/apt/sources.list.d/wine.list && \
  apt-get update && \
  apt-get install -y --no-install-recommends winehq-stable && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Create group and user with specified UID and GID
RUN groupadd -g ${GID} ${USER} && \
  useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER}

# Create necessary directories with proper ownership and permissions as root
RUN mkdir -p ${SERVER_DIR} && \
  mkdir -p ${CONFIG_DIR} && \
  mkdir -p ${WINE_PREFIX} && \
  chown -R ${USER}:${USER} ${DATA_DIR} && \
  chmod -R ${DATA_PERM} ${DATA_DIR}

# Copy server files from builder stage
COPY --from=builder /terratech-worlds $SERVER_DIR

# Copy the modified entrypoint script
COPY entrypoint.sh /serverdata/entrypoint.sh

# Set permissions on entrypoint script as root
RUN chmod +x /serverdata/entrypoint.sh

# Switch to the terratech user AFTER setting permissions
USER ${USER}

# Server Start
ENTRYPOINT ["/serverdata/entrypoint.sh"]
