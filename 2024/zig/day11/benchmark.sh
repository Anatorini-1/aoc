#!/usr/bin/env bash
sudo perf record -F 99    -g  -- ./run.sh
sudo perf script >out.perf
stackcollapse-perf.pl out.perf >collapsed
flamegraph.pl --color=java --hash collapsed >benchmark.svg
open benchmark.svg
