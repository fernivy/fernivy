#!/bin/bash

if [ -z "${FERNIVY_POWERLOG_PATH}" ]; then
	FERNIVY_POWERLOG_PATH="/Applications/Intel\ Power\ Gadget/PowerLog"
fi

eval "$FERNIVY_POWERLOG_PATH" -file $1 -cmd "$2"
