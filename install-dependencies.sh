#!/usr/bin/env bash
set -euo pipefail

SUDO=""
if [ "$(id -u)" -ne 0 ]; then
    SUDO="pkexec"
fi

$SUDO apt-get update
$SUDO apt-get install -y \
    build-essential \
    git \
    cmake \
    ninja-build \
    pkg-config \
    qt6-base-dev \
    qt6-base-dev-tools \
    qt6-tools-dev \
    qt6-tools-dev-tools \
    qt6-svg-dev \
    qt6-5compat-dev \
    qt6-l10n-tools \
    qt6-image-formats-plugins \
    libexiv2-dev \
    libraw-dev \
    libopencv-dev \
    libtiff-dev \
    libgl-dev \
    libgtest-dev
