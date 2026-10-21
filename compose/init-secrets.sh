#!/bin/sh
# Create the local Compose secret files once. Existing non-empty files are kept.
# The generated values are never printed by this script.
set -eu

umask 077
DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/secrets
mkdir -p "$DIR"

make_secret() {
    file=$1
    bytes=$2
    if [ -s "$file" ]; then
        chmod 600 "$file"
        echo "keep   $file"
        return
    fi
    printf '%s' "$(openssl rand -hex "$bytes")" > "$file"
    chmod 600 "$file"
    echo "create $file"
}

make_secret "$DIR/db_root_password.txt" 32
make_secret "$DIR/db_password.txt" 32
make_secret "$DIR/install_secret.txt" 32
make_secret "$DIR/admin_password.txt" 16

echo "Admin password file: $DIR/admin_password.txt"
echo "Do not commit this directory. It is ignored by Git."
