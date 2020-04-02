#!/bin/bash

if [[ -z $LABELS_PATH ]]; then
    touch /tmp/labels
    LABELS_PATH=/tmp/labels
elif [[ ! -f $LABELS_PATH ]]; then
    echo "LABELS_PATH=$LABELS_PATH: no such file"
    exit 1
fi

if command -v rg > /dev/null; then
    grep() { rg $@; }
fi

[[ $1 =~ -(.).* ]] && MODE=${BASH_REMATCH[1]}

add_label() {
    if [[ $1 =~ ^(.+):(.+)$ ]]; then
        PKG=${BASH_REMATCH[1]}
        LABEL=${BASH_REMATCH[2]}
        grep -m 1 "^$PKG:" "$LABELS_PATH" > /dev/null || echo "$PKG:" >> "$LABELS_PATH"
        sed -E -i'~' -e "s/^(${PKG}):.*$/\1: ${LABEL}/" "$LABELS_PATH"
    else
        PKG="$1"
    fi
}

delete_label() {
    PKG="$1"
    sed -i'~' -e "/^${PKG}:/d" "$LABELS_PATH"
}

case $MODE in
    S)
        PACMAN_INVOCATION='pacman'
        while [[ $# != 0 ]]; do
            add_label "$1"
            PACMAN_INVOCATION+=" $PKG"
            shift
        done
        echo $PACMAN_INVOCATION
        ;;
    Q)
        [[ $1 == *[qiklcps]* ]] && pacman $@ && exit

        IS_VERSION=0
        for PKG in $(pacman $@); do
            if [[ $IS_VERSION == 1 ]]; then
                IS_VERSION=0
                printf "$(tput setaf 2) %s\n$(tput sgr0)" $PKG
            else
                IS_VERSION=1
                printf "$(tput bold)%s" $PKG
                LABEL="$(grep -m 1 "^$PKG" "$LABELS_PATH")"
                LABEL=${LABEL##$PKG: }
                [[ -n $LABEL ]] && printf "$(tput setaf 1) [%s]" "$LABEL"
            fi
        done
        ;;
    L)
        OPTS=$1
        shift
        for PKG in $@; do
            [[ $OPTS == *[dr]* ]] && delete_label "$PKG"
            [[ $OPTS == *a* ]] && add_label "$PKG"
        done
        ;;
    *)
        pacman $@
        ;;
esac
