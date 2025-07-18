#!/bin/bash

set -e

project_root="./"
out_dir="${project_root}out"
dist_dir="${project_root}dist"

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
  echo "Compiling project..."
  rm -rf "${out_dir:?}/"*
  rm -rf "${dist_dir:?}/"*
  npx rbxtsc
  darklua process out dist -c darklua.json
}

build() {
  echo "Building file..."
  rojo build --output "game.rbxl" "darklua.project.json"
}

launch() {
  echo "Launching Roblox Studio.."
  start "./game.rbxl"
}

sync() {
  echo "Starting Rojo and watching for changes..."
  npx concurrently --kill-others "rbxtsc -w" "darklua process out dist -w -c darklua.json" "rojo serve darklua.project.json"
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
