

def extrapolateForeward(sequence):
    rows = [sequence]
    while not all(x == 0 for x in rows[-1]):
        newRow = []
        for i in range(len(rows[-1])-1):
            newRow.append(rows[-1][i+1] - rows[-1][i])
        rows.append(newRow)
    
    rows[-1].append(0)
    for i in range(len(rows)-1):
        j = len(rows) - i - 2
        rows[j].append(rows[j][-1] + rows[j+1][-1])
    return rows[0]

def extrapolateBackwards(sequence):
    rows = [sequence]
    while not all(x == 0 for x in rows[-1]):
        newRow = []
        for i in range(len(rows[-1])-1):
            newRow.append(rows[-1][i+1] - rows[-1][i])
        rows.append(newRow)
    
    rows[-1].insert(0,0)
    for i in range(len(rows)-1):
        j = len(rows) - i - 2
        rows[j].insert(0, rows[j][0] - rows[j+1][0])
    for r in rows:
        print(r)
        
    return rows[0]
   
def part1(data):
    sum = 0
    for d in data:
        sum += extrapolateForeward(d)[-1]
    print(sum)

def part2(data):
    sum = 0
    for d in data:
        sum += extrapolateBackwards(d)[0]
    print(sum)



if __name__ == '__main__':
    with open('input.txt') as f:
        data = [y.split(" ") for y in  f.read().splitlines()]
        for d in range(len(data)):
            data[d] = [int(x) for x in data[d]]
        
        #part1(data)
        part2(data)