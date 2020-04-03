#!/bin/bash
set -eu

LABELS_PATH=/etc/paclabel/labels
GREEN="$(tput setaf 2)"
WHITE="$(tput setaf 7)"
BOLD="$(tput bold)"
RESET="$(tput sgr0)"

set_labels() {
    if [[ $1 =~ ^(.+):(.+)$ ]]; then
        PKG="${BASH_REMATCH[1]}"
        LABELS="${BASH_REMATCH[2]}"
        grep -m 1 "^$PKG:" "$LABELS_PATH" > /dev/null || echo "$PKG:" >> "$LABELS_PATH"
        sed -E -i'~' -e "s/^(${PKG}):.*$/\1: ${LABELS}/" "$LABELS_PATH"
    else
        PKG="$1"
    fi
}

delete_labels() {
    PKG="$1"
    sed -i'~' -e "/^${PKG}:/d" "$LABELS_PATH"
}

# Use ripgrep instead of GNU grep if available.
if command -v rg > /dev/null; then
    grep() { rg "$@"; }
fi

[[ $1 =~ -(.).* ]] && MODE=${BASH_REMATCH[1]}

case $MODE in
    S)
        [[ $1 == *[sil]* ]] && exec pacman "$@"

        PACMAN_INVOCATION='pacman'
        while [[ $# != 0 ]]; do
            set_labels "$1"
            PACMAN_INVOCATION+=" $PKG"
            shift
        done
        exec $PACMAN_INVOCATION
        ;;
    Q)
        [[ $1 == *[qiklcps]* ]] && exec pacman "$@"

        IS_VERSION=0
        for PKG in $(pacman "$@"); do
            if [[ $IS_VERSION == 1 ]]; then
                IS_VERSION=0
                printf "$BOLD$GREEN $PKG\n$RESET"
            else
                IS_VERSION=1
                printf "$BOLD$PKG"

                set +e
                LABELS="$(grep -m 1 "^$PKG" "$LABELS_PATH")"
                set -e

                LABELS=${LABELS##$PKG: }

                COLOR=1
                for LABEL in $LABELS; do
                    BG="$(tput setab $COLOR)"
                    printf " $BG$BOLD$WHITE $LABEL $RESET"
                    COLOR=$((COLOR + 1))
                    [[ $COLOR == 2 ]] && COLOR=3
                    [[ $COLOR == 6 ]] && COLOR=1
                done
            fi
        done
        ;;
    L)
        OPTS=$1
        shift

        if [[ $OPTS == *[^-Ldrsl]* ]]; then
            echo "paclabel: invalid options: $OPTS" >&2
            exit 1
        fi

        for PKG in "$@"; do
            [[ $OPTS == *[dr]* ]] && delete_labels "$PKG"
            [[ $OPTS == *s* ]] && set_labels "$PKG"
        done

        [[ $OPTS == *l* ]] && cat "$LABELS_PATH"
        ;;
    *)
        exec pacman "$@"
        ;;
esac

exit 0
