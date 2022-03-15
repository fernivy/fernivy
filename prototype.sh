#!/bin/bash

############################################################
# Utility functions.                                       #
############################################################

log() {
    if [[ $_l -eq 1 ]]; then
        $@
    fi
}

print_help() {
    # Display Help
    echo "syntax: prototype [-h] [-l] [-s seconds_to_run | -c command_to_run]"
    echo "options:"
    echo "c     Run for specified command."
    echo "h     Print this Help."
    echo "l     Run in logging mode."
    echo "s     Run for specified amount of seconds."
    echo
}

############################################################
# Check whether mode is set.                               #
############################################################

set_mode() {
    log echo "Attempting to set mode to: "$1
    # if the mode variable is already set
    if [[ -v $MODE ]]; then
        # exit with an error
        echo -n "You can only use one mode. "
        echo    "Use either the -s or the -c tag."
        exit
    else
        # set the correct mode
        MODE=$1
        log echo "Mode is set to: "$MODE
    fi
    log echo
}

############################################################
# Set the default options.                                 #
############################################################

SECS=60
_l=0

############################################################
# Process the input options.                               #
############################################################

while getopts ":c:hls:" option; do
    case $option in
        c) # set to running for a command
            set_mode "CMD"
            CMD=$OPTARG;;
        h) # display Help
            print_help
            exit;;
        l) # set to verbose
            _l=1;;
        s) # set amount of seconds to run
            set_mode "TIMED"
            SECS=$OPTARG;;
        :) # missing argument
            echo "Error: Missing argument"
            exit;;
       \?) # Invalid option
            echo "Error: Invalid option"
            exit;;
    esac
done

if [[ -z $MODE ]]; then
    MODE="TIMED"
fi

############################################################
# Main programme.                                          #
############################################################

if [[ $MODE = "TIMED" ]]; then
    echo "Running for "$SECS" seconds."
else
    echo "Running for "$CMD" command."
fi


