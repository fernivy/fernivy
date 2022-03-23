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
    echo "syntax: prototype [-h] [-l] [-s seconds_to_run | -c command_to_run] [-e] [-p] [-t] [-o output_file_name | -f output_file_folder]"
    echo "options:"
    echo "c     Run for specified command. Put the entire command in quotation marks if it is longer than one word."
    echo "e     Print total energy consumption."
    echo "f     Set the folder in which to save the output file. If it does not exist, it will be created."
    echo "h     Print this Help."
    echo "l     Run in logging mode."
    echo "o     Set output file. The path to the file has to exist."
    echo "p     Print average power."
    echo "s     Run for specified amount of seconds."
    echo "t     Print total execution time."
    echo
}

############################################################
# Check whether mode is set.                               #
############################################################

set_mode() {
    log echo "Attempting to set mode to: "$1
    # if the mode variable is already set
    if [[ -x MODE ]]; then
        # set the correct mode
        MODE=$1
        log echo "Mode is set to: "$MODE
    else
        # exit with an error
        echo -n "You can only use one mode. "
        echo    "Use either the -s or the -c tag."
        exit
    fi
}

############################################################
# Set the default options.                                 #
############################################################

DT=`date | tr -d ' :'`

TOOL=powerlog

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

while getopts ":c:ef:hlo:ps:t" option; do
    case $option in
        c) # set to running for a command
            set_mode "CMD"
            CMD=$OPTARG
            log echo "Command set to: "$CMD;;
        e) # set energy flag
            _e=1;;
        f) # set output folder
            FLDR=$OPTARG
            log echo "Folder set to: "$FLDR;;
        h) # display Help
            print_help
            exit;;
        l) # set to verbose
            _l=1;;
        o) # set output file
            OUTPUT=$OPTARG;;
        p) # set power flag
            _p=1;;
        s) # set amount of seconds to run
            set_mode "TIMED"
            SECS=$OPTARG
            log echo "Runtime set to: "$SECS" s";;
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

if [[ -z MODE ]]; then
    MODE="TIMED"
    log echo "Mode is set to: "$MODE
fi

if [[ -n FLDR ]]; then
    OUTPUT=$FLDR"/"$OUTPUT
    if [ ! -d $FLDR ]; then
        mkdir $FLDR
        log echo "Created folder: "$FLDR
    fi
fi
log echo "Output file set to: "$OUTPUT

log echo

############################################################
# Main programme.                                          #
############################################################

if [[ $MODE = "CMD" ]]; then
    echo "Measuring command: "$CMD
else
    CMD="sleep "$SECS
fi

chmod +x $TOOL"_run.sh"
"./"$TOOL"_run.sh" "$CMD"

# Call parser to parse to $OUTPUT

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
