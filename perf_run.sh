#!/bin/bash

perf stat -e power/energy-psys/ -o $1 $2
