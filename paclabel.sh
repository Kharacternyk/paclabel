#!/bin/bash

[[ -z $LABELS_PATH ]] && LABELS_PATH=/tmp/labels

if command -v rg > /dev/null; then
    grep() { rg $@; }
fi

[[ $1 =~ -(.).* ]] && MODE=${BASH_REMATCH[1]}
echo $MODE

store_label() {
    PKG="$1"
    LABEL="$2"
    grep "$PKG:" "$LABELS_PATH" > /dev/null || echo "$PKG:" >> "$LABELS_PATH"
    sed -E -i'~' -e "s/^(${PKG}):.*$/\1: ${LABEL}/" "$LABELS_PATH"
}

case $MODE in
    S)
        PACMAN_INVOCATION='pacman'
        while [[ $# != 0 ]]; do
            if [[ $1 =~ ^(.+):(.+)$ ]]; then
                PACKAGE=${BASH_REMATCH[1]}
                LABEL=${BASH_REMATCH[2]}
                PACMAN_INVOCATION+=" $PACKAGE"
                store_label "$PACKAGE" "$LABEL"
                shift
            else
                PACMAN_INVOCATION+=" $1"
                shift
            fi
        done
        echo $PACMAN_INVOCATION
        ;;
    Q)
        [[ $1 == *q* ]] && pacman $@ && exit

        IS_VERSION=0
        for PKG in $(pacman $@); do
            if [[ $IS_VERSION == 1 ]]; then
                IS_VERSION=0
                printf "$(tput setaf 2) %s\n$(tput sgr0)" $PKG
            else
                IS_VERSION=1
                printf "$(tput bold)%s" $PKG
                LABEL="$(grep "^$PKG" "$LABELS_PATH")"
                LABEL=${LABEL##$PKG: }
                [[ -n $LABEL ]] && printf "$(tput setaf 1) [%s]" "$LABEL"
            fi
        done
        ;;
    *) ;;

esac
