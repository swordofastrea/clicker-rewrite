#!/bin/bash

set -e

project_root="./"
project_file="default.project.json"
out_dir="${project_root}out"
dist_dir="${project_root}dist"
game_file="game.rbxl"

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
  echo "Compiling project.."
  rm -rf "${out_dir:?}/"*
  rm -rf "${dist_dir:?}/"*
  mkdir -p ${out_dir}
  mkdir -p ${dist_dir}
  npx rbxtsc
  cp -r "${out_dir}/workspace" "${dist_dir}/workspace"
  darklua process out dist -c .darklua.json
}

build() {
  echo "Building file.."
  rojo build --output ${game_file} ${project_file}
}

launch() {
    raw_os="$(uname -s)"
    case "$raw_os" in
        Linux*)   os="Linux" ;;
        Darwin*)  os="macOS" ;;
        MINGW*|MSYS*|CYGWIN*|Windows_NT) os="Windows" ;;
        *)        os="" ;;
    esac

    if [[ -z "$os" ]]; then
        echo -e "Unsupported OS: $raw_os\nThis application supports only Windows and MacOS with Roblox Studio or Linux with Vinegar.\nIf you believe this is an error or want to request future support, please submit an issue here:\nhttps://github.com/swordofastrea/clicker-rewrite/issues"
        return 1
    fi
    echo "Operating System: $os"
    echo "Launching Roblox Studio.."
    case "$os" in
        Linux)
            xdg-open "${game_file}" 2>&1 &
            ;;
        macOS)
            open "${game_file}"
            ;;
        Windows)
            start "${game_file}"
            ;;
    esac
}



sync() {
  echo "Starting Rojo and watching for changes.."
  npx concurrently --kill-others "rbxtsc -w" "darklua process ${out_dir##*/} ${dist_dir##*/} -w -c .darklua.json" "rojo serve ${project_file}"
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
