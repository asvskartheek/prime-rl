#!/usr/bin/env bash

set -e

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

main() {

    log_info "Updating apt..."
    sudo apt update

    log_info "Installing git, tmux, htop, nvtop, cmake, python3-dev, cgroup-tools..."
    sudo apt install git tmux htop nvtop cmake python3-dev cgroup-tools -y

    log_info "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh

    log_info "Sourcing uv environment..."
    if ! command -v uv &> /dev/null; then
        source $HOME/.local/bin/env
    fi

    log_info "Installing dependencies in virtual environment..."
    uv sync && uv sync --extra fa
    log_info "Installation completed!"

    log_info "Logging into wandb..."
    uv run wandb login

    log_info "Logging into Hugging Face..."
    uv run huggingface-cli login

    log_info "Setting ulimit for open files..."
    ulimit -n 32000

    log_info "Setting up tmux session..."
    bash scripts/tmux.sh

    log_info "Install other dependencies..."
    uv add nltk textarena

    log_info "Starting Wordle training..."
    uv run rl \
    --trainer @ configs/trainer/wordle.toml \
    --orchestrator @ configs/orchestrator/wordle.toml \
    --inference @ configs/inference/wordle.toml
}

main