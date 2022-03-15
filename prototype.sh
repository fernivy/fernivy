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
    echo "syntax: prototype [-h] [-l] [-s seconds_to_run | -c command_to_run] [-o output_file_name]"
    echo "options:"
    echo "c     Run for specified command."
    echo "h     Print this Help."
    echo "l     Run in logging mode."
    echo "o     Set output file."
    echo "s     Run for specified amount of seconds."
    echo
}

############################################################
# Check whether mode is set.                               #
############################################################

set_mode() {
    # if the mode variable is already set
    if [[ -v $MODE ]]; then
        log echo "Attempting to set mode to: "$1
        # exit with an error
        echo -n "You can only use one mode. "
        echo    "Use either the -s or the -c tag."
        exit
    else
        # set the correct mode
        MODE=$1
        log echo "Mode is set to: "$MODE
    fi
}

############################################################
# Set the default options.                                 #
############################################################

DT=`date | tr -d ' :'`

SECS=60
OUTPUT=output_$DT.csv
_l=0

############################################################
# Process the input options.                               #
############################################################

while getopts ":c:hlo:s:" option; do
    case $option in
        c) # set to running for a command
            set_mode "CMD"
            CMD=$OPTARG
            log echo "Command set to "$CMD".";;
        h) # display Help
            print_help
            exit;;
        l) # set to verbose
            _l=1;;
        o) # set output file
            OUTPUT=$OPTARG
            log echo "Output file set to "$OUTPUT".";;
        s) # set amount of seconds to run
            set_mode "TIMED"
            SECS=$OPTARG
            log echo "Seconds set to "$SECS".";;
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
    log echo "Mode is set to: "$MODE
fi

log echo

############################################################
# Main programme.                                          #
############################################################

if [[ $MODE = "TIMED" ]]; then
    echo "Running for "$SECS" seconds."
else
    echo "Running for "$CMD" command."
fi

echo "Results exported to: "$OUTPUT


