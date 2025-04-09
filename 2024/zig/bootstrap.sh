#!/usr/bin/env bash

cp -r template $1

fdfind -t f . --exec sed -i "s/day11/$1/g" {}
