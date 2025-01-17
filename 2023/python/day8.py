import math


directions = []
paths = {}

def solve(start):
    current = start
    iterations = 0
    while current[-1] != 'Z':
        if directions[iterations%len(directions)] == 'L':
            current = paths[current][0]
        else:
            current = paths[current][1]
        iterations += 1
    return iterations
            
with open("input.txt") as data:
    directions = data.readline().strip()
    data.readline()
    paths = {}
    for path in data:
        p = path.strip().split(" = ")
        k = p[0]
        v = p[1][1:-1].split(", ")
        paths[k] = v




def part1():
    print(solve('AAA'))

def part2():
    startinPoints = []
    for k in paths.keys():
        if k[-1] == 'A':
            startinPoints.append(k)
    print(startinPoints)
    print(math.lcm(*[solve(s) for s in startinPoints]))

part1()
part2()  
            
