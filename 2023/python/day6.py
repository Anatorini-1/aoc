import re
with open("input.txt") as data:
    time = [ int(x.strip()) for x in re.findall("\d+",data.readline().split(":")[1].strip())]
    distance = [ int(x.strip()) for x in re.findall("\d+",data.readline().split(":")[1].strip())]
    res = 1
    r=len(time)
    for i in range(len(time)):
        print(i/r)
        t = time[i]
        d = distance[i]
        ways = 0
        for j in range(t):
            testDistance = j*(t-j)
            if testDistance > d:
                ways += 1
        res *= ways
    print(res)
            