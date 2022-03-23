#!/bin/bash

sudo perf stat -e power/energy-psys/ -o temp.txt $1
