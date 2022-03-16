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
    echo "syntax: prototype [-h] [-l] [-s seconds_to_run | -c command_to_run] [-e] [-p] [-t] [-o output_file_name]"
    echo "options:"
    echo "c     Run for specified command."
    echo "e     Print total energy consumption."
    echo "h     Print this Help."
    echo "l     Run in logging mode."
    echo "o     Set output file."
    echo "p     Print average power."
    echo "s     Run for specified amount of seconds."
    echo "t     Print total execution time."
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

ENERGY=$RANDOM
_e=0
POWER=$RANDOM
_p=0
TIME=$RANDOM
_t=0

############################################################
# Process the input options.                               #
############################################################

while getopts ":c:ehlo:ps:t" option; do
    case $option in
        c) # set to running for a command
            set_mode "CMD"
            CMD=$OPTARG
            log echo "Command set to "$CMD".";;
        e) # set energy flag
            _e=1;;
        h) # display Help
            print_help
            exit;;
        l) # set to verbose
            _l=1;;
        o) # set output file
            OUTPUT=$OPTARG
            log echo "Output file set to "$OUTPUT".";;
        p) # set power flag
            _p=1;;
        s) # set amount of seconds to run
            set_mode "TIMED"
            SECS=$OPTARG
            log echo "Seconds set to "$SECS".";;
        t) # set time flag
            _t=1;;
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

if [[ $MODE = "CMD" ]]; then
    echo "Measuring command: "$CMD
fi

if [[ $_e -eq 1 ]]; then
    echo "Total energy consumption: "$ENERGY" J"
fi
if [[ $_p -eq 1 ]]; then
    echo "Average power: "$POWER" W"
fi
if [[ $_t -eq 1 ]]; then
    echo "Total time elapsed: "$TIME" s"
fi

echo "Results exported to: "$OUTPUT


