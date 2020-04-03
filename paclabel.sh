#!/bin/bash

LABELS_PATH=/etc/paclabel
GREEN="$(tput setaf 2)"
WHITE="$(tput setaf 7)"
BOLD="$(tput bold)"
RESET="$(tput sgr0)"

if command -v rg > /dev/null; then
    grep() { rg "$@"; }
fi

[[ $1 =~ -(.).* ]] && MODE=${BASH_REMATCH[1]}

set_labels() {
    if [[ $1 =~ ^(.+):(.+)$ ]]; then
        PKG="${BASH_REMATCH[1]}"
        LABEL="${BASH_REMATCH[2]}"
        grep -m 1 "^$PKG:" "$LABELS_PATH" > /dev/null || echo "$PKG:" >> "$LABELS_PATH"
        sed -E -i'~' -e "s/^(${PKG}):.*$/\1: ${LABEL}/" "$LABELS_PATH"
    else
        PKG="$1"
    fi
}

delete_labels() {
    PKG="$1"
    sed -i'~' -e "/^${PKG}:/d" "$LABELS_PATH"
}

case $MODE in
    S)
        PACMAN_INVOCATION='pacman'
        while [[ $# != 0 ]]; do
            set_labels "$1"
            PACMAN_INVOCATION+=" $PKG"
            shift
        done
        $PACMAN_INVOCATION
        ;;
    Q)
        [[ $1 == *[qiklcps]* ]] && pacman "$@" && exit

        IS_VERSION=0
        for PKG in $(pacman "$@"); do
            if [[ $IS_VERSION == 1 ]]; then
                IS_VERSION=0
                printf "$BOLD$GREEN $PKG\n$RESET"
            else
                IS_VERSION=1
                printf "$BOLD$PKG"
                LABELS="$(grep -m 1 "^$PKG" "$LABELS_PATH")"
                LABELS=${LABELS##$PKG: }

                COLOR=1
                for LABEL in $LABELS; do
                    BG="$(tput setab $COLOR)"
                    printf " $BG$BOLD$WHITE $LABEL $RESET"
                    COLOR=$((COLOR + 1))
                    [[ $COLOR == 6 ]] && COLOR=1
                done
            fi
        done
        ;;
    L)
        OPTS=$1
        shift

        for PKG in "$@"; do
            [[ $OPTS == *[dr]* ]] && delete_labels "$PKG"
            [[ $OPTS == *s* ]] && set_labels "$PKG"
        done

        [[ $OPTS == *l* ]] && cat "$LABELS_PATH"
        ;;
    *)
        pacman "$@"
        ;;
esac

exit 0
