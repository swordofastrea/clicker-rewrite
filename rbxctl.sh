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
  echo "  -b, --build       Build the project and starts watching for changes (clean, compile, build .rbxl, watch)"
  echo "  -s, --serve       Start the Rojo server"
  echo "  -l, --launch      Launch Roblox Studio with game.rbxl"
  echo "  -a, --all         Run build, serve, launch in order"
  echo "  -h, --help        Show this help message"
  echo
  echo "Example:"
  echo "  $0 --all"
}

build() {
  echo "Cleaning ${out_dir}..."
  rm -rf "${out_dir:?}/"*
  echo "Compiling project..."
  npx rbxtsc -w "$project_root"
  echo "Building .rbxl place file..."
  rojo build -o "game.rbxl" "${project_root}default.project.json"
}

serve() {
  echo "Starting Rojo server..."
  rojo serve "$project_root"
}

launch() {
  echo "Launching Roblox Studio.."
  start "" "RobloxStudioLauncher.exe" "$place_file"
}

run_all() {
  build
  serve
  launch
}

if [[ $# -eq 0 ]]; then
  echo "No arguments provided. Use -h or --help to see usage."
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    -b|--build)
      build
      shift
      ;;
    -s|--serve)
      serve
      shift
      ;;
    -l|--launch)
      launch
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
