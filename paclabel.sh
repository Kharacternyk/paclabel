#!/bin/bash

PACMAN_INVOCATION='pacman'

while [[ $# != 0 ]]; do
    if [[ $1 =~ ^(.*):(.*)$ ]]; then
        PACKAGE=${BASH_REMATCH[1]}
        LABEL=${BASH_REMATCH[2]}
        echo 'Package:' $PACKAGE
        echo 'Label:' $LABEL
        PACMAN_INVOCATION+=" $PACKAGE"
        shift
    else
        PACMAN_INVOCATION+=" $1"
        shift
    fi
done

echo $PACMAN_INVOCATION
