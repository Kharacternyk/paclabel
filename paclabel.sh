#!/bin/bash

[[ $1 =~ -(.).* ]] && MODE=${BASH_REMATCH[1]}
echo $MODE

case $MODE in
    S)
        PACMAN_INVOCATION='pacman'
        while [[ $# != 0 ]]; do
            if [[ $1 =~ ^(.+):(.+)$ ]]; then
                PACKAGE=${BASH_REMATCH[1]}
                LABEL=${BASH_REMATCH[2]}
                PACMAN_INVOCATION+=" $PACKAGE"
                echo $PACKAGE:$LABEL >> /tmp/labels
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
                printf ' %s\n' $PKG
            else
                IS_VERSION=1
                printf '%s' $PKG
                LABEL="$(grep $PKG /tmp/labels)"
                [[ -n $LABEL ]] && printf " : %s" $LABEL
            fi
        done
        ;;
    *) ;;

esac
