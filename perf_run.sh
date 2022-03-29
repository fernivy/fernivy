#!/bin/bash

echo $2

sudo perf stat -e power/energy-psys/ -o temp$1.txt $2
