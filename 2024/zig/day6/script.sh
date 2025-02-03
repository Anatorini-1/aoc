./zig-out/bin/day4 ./input.txt &

PID=$!
echo $PID
perf record -F 99 -p $PID -g -- sleep 5
wait
