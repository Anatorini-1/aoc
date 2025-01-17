import os

os.system("cls")

def applyRangeTransform(rStart,rEnd,tStart,tEnd,tDiff):
    if rStart < tStart:
        if rEnd <= tStart:
            return [[rStart,rEnd]]
        elif rEnd > tStart and rEnd <= tEnd:
            return [
                [rStart,tStart],
                [tStart+tDiff,rEnd+tDiff]
            ]
        elif rEnd > tEnd:
            return [
                [rStart,tStart],
                [tStart+tDiff,tEnd+tDiff],
                [tEnd,rEnd],
            ]
    elif rStart >= tStart and rStart < tEnd:
        if rEnd <= tStart:
            # This shouldn't happen, means range end<start
            raise Exception("Invalid range")
        elif rEnd > tStart and rEnd <= tEnd:
             return [
                [rStart+tDiff,rEnd+tDiff]
            ]
        elif rEnd > tEnd:
            return [
                [rStart+tDiff,tEnd+tDiff],
                [tEnd,rEnd]
            ]
    elif rStart >= tEnd:
        if rEnd <= tStart:
            raise Exception("Invalid range")
        elif rEnd > tStart and rEnd <= tEnd:
            raise Exception("Invalid range")
        elif rEnd > tEnd:
            return [[rStart,rEnd]]
            
     
    
        
            


def part1():
    with open("input.txt") as data:
        data = data.read()
        mappings = data.split("\n\n")
        seeds = [int(s) for s in mappings[0].split(":")[1].strip().split(" ")]
        mappings = mappings[1:]
        for maps in mappings:
            ns = [s for s in seeds]
            for m in maps.split("\n")[1:]:
                #print(m)
                map_parts = [int(mp) for mp in m.strip().split(" ")]
                dst = map_parts[0]
                src = map_parts[1]
                rng = map_parts[2]
                for i,v in enumerate(seeds):
                    if v >= src and v < src+rng:
                       ns[i] = dst+(v-src)
            seeds = ns
            print(ns)
            #print("map ",maps.split("\n")[0]," done")
        print(min(seeds))

def part2():
    with open("input.txt") as data:
        data = data.read()
        mappings = data.split("\n\n")
        seeds = [int(s) for s in mappings[0].split(":")[1].strip().split(" ")]
        seeds2 = []
        for i in range(0,len(seeds),2):
            seeds2.append([seeds[i],seeds[i+1]+seeds[i]])
        seeds = seeds2
        mappings = mappings[1:]
        for maps in mappings:
            ns = []
            #print(seeds) 
            for s in seeds:
                tmp = [x for x in ns]
                for m in maps.split("\n")[1:]:
                    map_parts = [int(mp) for mp in m.strip().split(" ")]
                    tStart = map_parts[1]
                    tEnd = map_parts[2] + tStart
                    tDiff = map_parts[0]-tStart
                    x = applyRangeTransform(s[0],s[1],tStart,tEnd,tDiff)
                    if x != [s]:
                        for y in x:
                            ns.append(y)
                        break
                if tmp == ns:
                    ns.append(s)
            seeds = ns if not len(ns) == 0 else seeds
            print("map ",maps.split("\n")[0]," done")   
            #print(seeds)         
        min = 2**32
        for r in seeds:
            if r[0] < min:
                min = r[0]
        print(min)
        
#part1()
part2()


