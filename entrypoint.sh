#!/bin/bash

USAGE="\nContainer Usage:\n docker run -v {abs-path-to-host-working-folder}:/gantree --rm -ti gantree-cli [arguments]"

if [ ! -d "/gantree" ]; then
    echo -e $USAGE
    exit 1
fi

if [ ! -d "/gantree/state" ]; then
    echo -e "\nstate directory not found, creating.."
    mkdir /gantree/state
fi

if [ ! -d "/gantree/config" ]; then
    echo -e "\nconfig directory not found, creating.."
    mkdir /gantree/config
fi

echo -e "\n"

gantree-cli "$@"
