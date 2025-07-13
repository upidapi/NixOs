#!/bin/env bash

url="https://paste.upidapi.dev"

# headers=""
declare -a headers=()

header() {
  headers+=("--header" "$1")
}

show_help_message() {
  echo "Usage: $0 [OPTIONS] <file|directory>"
  echo "  Uploads a file or directory to a server."
  echo
  echo "Options:"
  echo "  -1                  Limit the download count to 1."
  echo "  -n | --never        Disable expiry (never expire)."
  echo "  -u | --url          URL to connect to."
  echo "  -d | --days <days>  Set the maximum number of days until expiry."
  echo "                      Defaults to 30 days."
  echo "  -p | --pass <password> Encrypt using a password."
  echo "                      Shows decryption instructions."
  echo "  --help              Display this help message and exit."
  echo
  echo "Examples:"
  echo "  $0 my_file.txt"
  echo "  $0 -1 -d 7 my_directory"
  echo "  $0 -n important_file.doc"
  echo "  $0 --pass 'secret phrase' sensitive_data.txt"
}

# TODO: add a get functionality

downloads=
expiery="Max-Days: 30"

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
  -1)
    downloads=1
    shift
    ;;
  -n | --never)
    shift
    expiery=
    ;;
  -d | --days)
    shift
    expiery="Max-Days: $1"
    shift
    ;;
  -u | --url)
    shift
    url=$1
    shift
    ;;
  -p | --pass)
    shift
    header "X-Encrypt-Password: $1"

    echo "you will need to use the folowing to decrypt" >&2
    echo "-H \"X-Encrypt-Password: $1\"" >&2
    shift
    ;;
  --help)
    show_help_message
    exit 0
    ;;
  # -h | --header)
  #   shift
  #   header "$1"
  #   shift
  #   ;;
  *)
    # Default: Assume this is the filename
    break # Exit the while loop; remaining args are filename and potentially others
    ;;
  esac
done

if [ -n "$downloads" ]; then
  header "Max-Downloads: $downloads"
fi

header "$expiery"

if [ $# -eq 0 ]; then
  echo "Error: No filename specified." >&2
  show_help_message
fi

cleanup() {
  rm -f "$file"
}

file_name=$(basename "$1")
if [ -t 0 ]; then
  file="$1"
  if [ ! -e "$file" ]; then
    echo "$file: No such file or directory" >&2
    exit 1
  fi

  if [ -d "$file" ]; then
    echo "Creating zip archive of $(realpath "$file") ..." >&2

    cd "$file" || exit 1
    file_name="$file_name.zip"

    file=$(mktemp /tmp/XXXXXX.zip)
    rm "$file"

    zip -r -q "$file" .

    trap cleanup EXIT
  fi

else
  file=$(mktemp "/tmp/XXXXXX.$file_name")
  cat >"$file"
  trap cleanup EXIT
fi

echo "Uploading file..." >&2
data=$(
  curl \
    --dump-header - \
    --show-error \
    --progress-bar \
    "${headers[@]}" \
    --upload-file "$file" \
    "$url/$file_name"
)

if [[ -z $data ]]; then
  echo "Server didnt send anything back" >&2 
  echo "Are you using the correcty url / is the server running?" >&2 
  exit 1
fi

url=$(echo "$data" | tail -n1)

# echo "$data"

del_url=$(echo "$data" | grep x-url-delete | awk '{print $2}')

echo >&2
echo "To delete use" >&2
echo "curl -X DELETE $del_url" >&2

echo >&2
echo "$url"
