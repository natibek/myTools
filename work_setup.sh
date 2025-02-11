#!/usr/bin/env bash

source ~/.bashrc

gnome-terminal --working-directory=$WORK_DIR1 -- bash -c ". .venv/bin/activate && nvim .; exec bash" --working-directory=$WORK_DIR2 -- bash -c ". .venv/bin/activate && nvim .; exec bash"
