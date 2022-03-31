#!/bin/bash

############################################################
# Utility functions.                                       #
############################################################

log() {
    if [[ $_l -eq 1 ]]; then
        "$@"
    fi
}

loading_bar(){
	STRING="|"
	for (( j=0; j<$2;         j++ )); do STRING+="#"; done
	for (( k=0; k<$(($1-$2)); k++ )); do STRING+="-"; done
	STRING+="| ${2}/${1}"

	if [ $2 -lt $1 ]; then
		echo -ne "$STRING\r"
		sleep $SLP
	else
		echo "$STRING"
	fi
}

print_help() {
    # Display Help
    echo "syntax:"
    echo "  fernivy [-h] [-l]"
    echo "          [-s seconds_to_run | -c command_to_run]"
    echo "          [-r number_of_runs] [-b seconds_between_runs]"
    echo "          [-e] [-p] [-t]"
    echo "          [-o output_file_name] [-f output_file_folder]"
    echo "options:"
    echo "b     Set the number of second to pause between runs."
    echo "c     Run for specified command."
    echo "      Put the entire command in quotation marks if it is longer than one word."
    echo "e     Print total energy consumption."
    echo "f     Set the folder in which to save the output file."
    echo "      If it does not exist, it will be created."
    echo "h     Print this Help."
    echo "l     Run in logging mode."
    echo "o     Set output file."
    echo "      The path to the file has to exist."
    echo "p     Print average power."
    echo "r     Set the number of times to run."
    echo "s     Run for specified number of seconds."
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
RUNS=1
SLP=30
OUTPUT=output_$DT.csv
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

# Request for sudo access

while getopts ":b:c:ef:hlo:pr:s:t" option; do
    case $option in
        b) # set break between runs
            SLP=$OPTARG;;
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
        r) # set number of runs
            RUNS=$OPTARG
            log echo "Number of runs set to: "$RUNS;;
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
        mkdir -p $FLDR
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
    echo ""
    echo ""
else
    CMD="sleep "$SECS
fi

TMP=$( mktemp )
for (( i=0; i<RUNS; i++ ))
do
    F=$( mktemp )
    "./"$TOOL"_run.sh" $F "$CMD" &>/dev/null

    echo $F >> $TMP

	  loading_bar $RUNS $(($i+1))
done

python3 parser.py -m $TOOL -o $OUTPUT -i $TMP

if [[ $_s -eq 1 ]]; then

    RESULT=$( sed -n '$p' $OUTPUT )

    echo ""
    IFS=',' read -ra ADDR <<< "$RESULT"
    if [[ $_e -eq 1 ]]; then
        echo "Average total energy consumption: "${ADDR[2]}" J"
    fi
    if [[ $_p -eq 1 ]]; then
        echo "Average power: "${ADDR[3]}" W"
    fi
    if [[ $_t -eq 1 ]]; then
        echo "Average total time elapsed: "${ADDR[4]//[$'\t\r\n ']}" s"
    fi
    echo ""
fi

echo "Results exported to: "$OUTPUT
