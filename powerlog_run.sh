#!/bin/bash

if [ -z "${FERNIVY_POWERLOG_PATH}" ]; then
	FERNIVY_POWERLOG_PATH="/Applications/Intel\ Power\ Gadget/PowerLog"
fi

eval "$FERNIVY_POWERLOG_PATH" -file temp$1.csv -cmd "$2"
