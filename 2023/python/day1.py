import os
import re

digits = [
        "zero",
        "one",
        "two",
        "three",
        "four",
        "five",
        "six",
        "seven",
        "eight",
        "nine"
    ]
def charFilter(c):
    if c >= '0' and c <= '9':
        return True
    else: return False

   
def findFirstDigit(line:str):
    a = []
    b = []
    for d,di in enumerate(digits): 
        index = [y.start() for y in re.finditer(di,line)]
        for x in index:
            a.append(x)
            b.append(d)
    for d in range(10): 
        index = [y.start() for y in re.finditer(str(d),line)]
        for x in index:
            a.append(int(x))
            b.append(d)
    #print(b,a)
    i = a.index(min(a))
    j = a.index(max(a))
    return 10*b[i]+b[j]
     

if __name__ == "__main__": 
    with open("day1data.txt", "r") as data:
        sum = 0;
        for line in data:
            sum += findFirstDigit(line)
        print(sum)

