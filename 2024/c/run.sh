#!/usr/bin/env bash

exe="$1"
src="$1.c"
input="$1.txt"

gcc $src -o $exe -g
./$exe $input
