import re
import itertools
dataset = []

def searchForEnginePart(x1,x2,y):
    if x1 > 0: x1 -= 1
    if x2+1 < len(dataset[y]): x2 += 1
    yRange = []
    yRange.append(y-1 if y > 0 else y)
    yRange.append(y+2 if y+1 < len(dataset) else y+1)
    for line in range(yRange[0], yRange[1]):
        for column in range(x1,x2):
            c = dataset[line][column]
            if not ord(c) in range(ord('0'),ord('9')+1) and not c == '.':
                return c
    return '.'




def zad1():
    with open("day3data.txt") as data:
        sum = 0
        dataset = [line for line in data]
        for index,line in enumerate(dataset):
            offset = 0
            nums = re.finditer("\d+",line[offset:])
            for n in nums:
                if searchForEnginePart(n.start(), n.end(), index) != ".":
                    #print(searchForEnginePart(n.start(), n.end(), index), n.group())
                    sum += int(n.group())
        print(sum)
        
def zad2():
    with open("day3data.txt") as data:
        sum = 0
        dataset = [line for line in data]
        for index,line in enumerate(dataset):
            offset = 0
            gears = re.finditer("\*",line)
            for gear in gears:
                x = gear.start()
                y = index
                parts = []
                nums = re.finditer("\d+",dataset[y])
                if y > 0:
                    nums = itertools.chain(nums,re.finditer("\d+",dataset[y-1]))
                if y+1 < len(dataset):
                    nums = itertools.chain(nums,re.finditer("\d+",dataset[y+1]))
                for n in nums:
                        if n.start() in range(x-1,x+2) or n.end()-1 in range(x-1,x+2):
                            parts.append(int(n.group()))
                if len(parts) == 2:
                    sum += parts[0]*parts[1]
                    print(gear.group(), parts)
        print(sum)
        

zad2()
            
  

