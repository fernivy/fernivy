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
    echo "o     Set output file. The path to the file has to exist. Cannot be \"temp\"."
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
    if [[ $_m -eq 1 ]]; then
        # exit with an error
        echo -n "You can only use one mode. "
        echo    "Use either the -s or the -c tag."
        exit
    else
        # set the correct mode
        MODE=$1
        _m=1
        log echo "Mode is set to: "$MODE
    fi
}

############################################################
# Set the default options.                                 #
############################################################

DT=`date | tr -d ' :'`

TOOL=perf

SECS=60
OUTPUT=output_$DT
_l=0

_m=0 # bool for setting mode
_f=0 # bool for setting folder

_s=0 # trool for printing any of the following:
_e=0 # energy
_p=0 # power
_t=0 # time elapsed

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
            _s=1
            _e=1;;
        f) # set output folder
            FLDR=$OPTARG
            _f=1
            log echo "Folder set to: "$FLDR;;
        h) # display Help
            print_help
            exit;;
        l) # set to verbose
            _l=1;;
        o) # set output file
            OUTPUT=$OPTARG;;
        p) # set power flag
            _s=1
            _p=1;;
        s) # set amount of seconds to run
            set_mode "TIMED"
            SECS=$OPTARG
            log echo "Runtime set to: "$SECS" s";;
        t) # set time flag
            _s=1
            _t=1;;
        :) # missing argument
            echo "Error: Missing argument"
            exit;;
       \?) # Invalid option
            echo "Error: Invalid option"
            exit;;
    esac
done

if [[ $_m -eq 0 ]]; then
    MODE="TIMED"
    _m=1
    log echo "Mode is set to: "$MODE
fi

if [[ $_f -eq 1 ]]; then
    OUTPUT=$FLDR"/"$OUTPUT
    if [ ! -d $FLDR ]; then
        mkdir $FLDR
        log echo "Created folder: "$FLDR
    fi
else
    if [[ $OUTPUT = "temp" ]]; then
        echo "You cannot set the output file to be \"temp\"."
        exit
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
"./"$TOOL"_run.sh" "$CMD" &>/dev/null

python3 parser.py -m $TOOL -t $DT -o $OUTPUT

if [[ $TOOL = "perf" ]] && [[ $_s -ne 2 ]]; then
    rm -f temp.txt
elif [[ $TOOL = "powerlog" ]] || [[ $_s -eq 2 ]]; then
    rm -f temp.csv
fi

if [[ $_s -eq 1 ]]; then

    RESULT=$( cat $OUTPUT.csv | sed -n 2p )
    
    THING="i"
    
    IFS=',' read -ra ADDR <<< "$RESULT"
    for i in "${ADDR[@]}"; do
        # index
        if [[ $THING = "i" ]]; then
            THING="ts"
        # timestamp
        elif [[ $THING = "ts" ]]; then
            THING="e"
        # energy consumption
        elif [[ $THING = "e" ]]; then
            if [[ $_e -eq 1 ]]; then
                echo "Total energy consumption: "$i" J"
            fi
            THING="p"
        # power
        elif [[ $THING = "p" ]]; then
            if [[ $_p -eq 1 ]]; then
                echo "Average power: "$i" W"
            fi
            THING="t"
        # time elapsed
        elif [[ $THING = "t" ]]; then
            if [[ $_t -eq 1 ]]; then
                echo "Total time elapsed: "$i" s"
            fi
            THING=""
        fi
    done
fi

echo "Results exported to: "$OUTPUT".csv"