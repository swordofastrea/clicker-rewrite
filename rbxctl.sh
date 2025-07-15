#!/bin/bash

# ----------------------------------------
# Usage Guide
# ----------------------------------------
# This script helps you build and run your Roblox-TS project with Rojo.
#
# Commands:
#   -b, --build       Clean the out directory, compile project, build the .rbxl, and watch for changes
#   -s, --serve       Start the Rojo server (background process)
#   -l, --launch      Launch Roblox Studio with the built game.rbxl
#   -a, --all         Run all of the above commands in this order:
#                       build → serve → launch → watch
#   -h, --help        Show a brief usage summary
#
# Example usage:
#   ./rbxctl.sh --all
#   ./rbxctl.sh --build
#   ./rbxctl.sh --watch
#
# Notes:
# - The compiled Luau files go to the 'out' folder.
# - game.rbxl is built in the root directory.
# - Project always does rbxtsc -w
#
# ----------------------------------------

set -e

project_root="./"      # Root directory containing default.project.json & game.rbxl
src_dir="${project_root}src"
out_dir="${project_root}out"

print_help() {
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "Options:"
  echo "  -c, --compile     Compile the project"
  echo "  -b, --build       Build the .rbxl"
  echo "  -l, --launch      Launch Roblox Studio with game.rbxl"
  echo "  -s, --sync        Start the Rojo server and watch for changes"
  echo "  -a, --all         Run all of the above commands in this order:"
  echo "                      compile → build → launch → sync"
  echo "  -h, --help        Show this help message"
  echo
  echo "Example:"
  echo "  $0 --all"
}

compile() {
  echo "compiling project..."
  rm -rf "${out_dir:?}/"*
  npx rbxtsc
}

build() {
  echo "building file..."
  rojo build --output "game.rbxl" "default.project.json"
}

launch() {
  echo "Launching Roblox Studio.."
  start "./game.rbxl"
}

sync() {
  echo "starting Rojo and watching for changes..."
  npx concurrently --kill-others "rojo serve" "npx rbxtsc -w"
}

run_all() {
  compile
  build
  launch
  sync
}

if [[ $# -eq 0 ]]; then
  echo "No arguments provided. Use -h or --help to see usage."
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    -c|--compile)
      compile
      shift
      ;;
    -b|--build)
      build
      shift
      ;;
    -l|--launch)
      launch
      shift
      ;;
    -s|--sync)
      sync
      shift
      ;;
    -a|--all)
      run_all
      shift
      ;;
    -h|--help)
      print_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      print_help
      exit 1
      ;;
  esac
done
