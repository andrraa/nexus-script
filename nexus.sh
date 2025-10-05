#!/bin/bash

set -e

REPO_URL="https://github.com/kira1752/nexus-cli.git"
REPO_DIR="$HOME/nexus-cli"
BIN_PATH="/usr/local/bin/nexus-network"

echo "=== NEXUS NETWORK SETUP / UPDATE SCRIPT ==="

# ==============================
#  INPUT FROM USER
# ==============================
read -p "Node ID: " NODE_ID
read -p "Max Threads: " MAX_THREADS
read -p "Max Difficulty: " MAX_DIFFICULTY

echo
echo "Node ID        : $NODE_ID"
echo "Max Threads    : $MAX_THREADS"
echo "Max Difficulty : $MAX_DIFFICULTY"
echo

# ==============================
#  INSTALL DEPENDENCY
# ==============================
echo "=== [1/6] INSTALLING DEPENDENCY ==="
sudo apt update -y
sudo apt install -y build-essential pkg-config libssl-dev protobuf-compiler git curl

# ==============================
#  INSTALL RUST
# ==============================
echo "=== [2/6] INSTALLING RUST ==="
if ! command -v cargo &> /dev/null; then
    echo "RUST not detected, installing..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
else
    echo "RUST detected, skipping..."
fi

# ==============================
#  CLONE / UPDATE REPO
# ==============================
echo "=== [3/6] REPO CHECKING ==="
if [ ! -d "$REPO_DIR" ]; then
    echo "Repo not detected, cloning..."
    git clone "$REPO_URL" "$REPO_DIR"
else
    echo "Repo detected, updating..."
    cd "$REPO_DIR"
    git reset --hard
    git pull
fi

# ==============================
#  BUILD PROJECT
# ==============================
echo "=== [4/6] Building nexus-network ==="
cd "$REPO_DIR/clients/cli"
cargo build --release

# ==============================
#  INSTALL BINARY
# ==============================
echo "=== [5/6] Installing nexus-network ==="
sudo cp target/release/nexus-network "$BIN_PATH"
sudo chmod +x "$BIN_PATH"

# ==============================
#  RUNNING NODE
# ==============================
echo "=== [6/6] Running nexus-network ==="
$BIN_PATH start --node-id "$NODE_ID" --max-threads "$MAX_THREADS" --max-difficulty "$MAX_DIFFICULTY"