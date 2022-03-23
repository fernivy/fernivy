#!/bin/bash

PL="/Applications/Intel\ Power\ Gadget/PowerLog"
eval "$PL" -file temp.csv -cmd $1
