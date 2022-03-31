#!/bin/bash

perf stat -e power/energy-psys/ -o temp$1.txt $2
