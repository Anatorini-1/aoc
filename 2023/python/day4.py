def part1():
    with open("input.txt") as data:
        sum = 0
        for line in data:
            n = [list(filter(lambda z: z != "", y)) for y in [x.strip().split(" ") for x in line.split(":")[1].split(" | ")]]
            score = len(list(filter(lambda x: x in n[1],n[0])))
            sum += 2**(score-1) if score > 0 else 0
        print(sum)
#part1()

def part2():
    with open("input.txt") as data:
        sum = 0
        lastCard = 220
        cardCount = {}
        for i in range(1,lastCard):
            cardCount[i] = 1
        for index,line in enumerate(data):
            n = [list(filter(lambda z: z != "", y)) for y in [x.strip().split(" ") for x in line.split(":")[1].split(" | ")]]
            score = len(list(filter(lambda x: x in n[1],n[0])))
            #print("Card ",(index+1),"score ",score)
            for i in range(index+2,index+score+2):
                cardCount[i] += cardCount[index+1]

        for k in cardCount.keys():
            #print("Card ",k," score ",cardCount[k])
            sum += cardCount[k]
        print(sum)
    
part2()