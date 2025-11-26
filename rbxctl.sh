#!/bin/bash
set -e

project_root="./"
out_dir="${project_root}out"
dist_dir="${project_root}dist"
game_file="game.rbxl"

if [[ -z "$1" || "$1" != *.project.json ]]; then
    echo "Error: You must specify a project file ending with .project.json"
    echo "Usage: $0 <project_file> <options>"
    exit 1
fi

project_file="$1"
shift

print_help() {
  echo "Usage: $0 <project_file> <options>"
  echo
  echo "Options:"
  echo "  -b, --build       Build the project"
  echo "  -l, --launch      Launch Roblox Studio with the built file"
  echo "  -a, --all         Run both commands in order:"
  echo "                      compile → launch"
  echo "  -h, --help        Show this help message"
  echo
  echo "Examples:"
  echo "  $0 default.project.json -c -b -s"
  echo "  $0 production.project.json -a"
}

build() {
  echo "Compiling project.."
  rm -rf "${out_dir:?}/"*
  rm -rf "${dist_dir:?}/"*
  mkdir -p ${out_dir}
  mkdir -p ${dist_dir}
  pnpm rbxtsc
  cp -r "${out_dir}/workspace" "${dist_dir}/workspace"
  darklua process out dist -c .darklua.json
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
    if [[ "$project_file" == "production.project.json" ]]; then
        echo "Starting Rojo for prod.."
        pnpm concurrently --kill-others "rbxtsc -w" "darklua process ${out_dir##*/} ${dist_dir##*/} -w -c .darklua.json" "rojo serve ${project_file}"
    else
        echo "Starting Rojo for dev.."
        pnpm concurrently --kill-others --raw "rbxtsc -w" "rojo serve ${project_file}"
    fi
}

run_all() {
  build
  launch
}

if [[ $# -eq 0 ]]; then
  echo "Error: No options provided. Use -h or --help to see usage."
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    -b|--build)
      build
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
