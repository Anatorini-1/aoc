# 1. Load Data                      : List(Hand)
# 2. Assign a "type" to each hand   : Map(Hand -> Type)
# 3. Hand coparator function (by type, then by high card)
# 4. Sort hands by comparator 
import re
cardStrength = {
    'J': 0,
    '2': 1,
    '3': 2,
    '4': 3,
    '5': 4,
    '6': 5,
    '7': 6,
    '8': 7,
    '9': 8,
    'T': 9,
    'Q': 11,
    'K': 12,
    'A': 13
}


typeStrengths = {
    "highCard": 0,
    "pair": 1,
    "twoPair": 2,
    "threeOfAKind": 3,
    "fullHouse": 4,
    "fourOfAKind": 5,
    "fiveOfAKind": 6,
    
}
def charCount(hand):
    counts = {}
    for c in hand:
        if c in counts:
            counts[c] += 1
        else:
            counts[c] = 1
    return counts


def typeClassifier(hand):
    if hand == "JJJJJ":
        return "fiveOfAKind"
    if 'J' in hand:
        possibleTypes = []
        for c in hand:
            if c == 'J':
                pass
            else:
                possibleTypes.append(typeClassifier(re.sub('J',c,hand,1)))
        return max(possibleTypes,key=typeStrengths.get)   
     
    charCounts = charCount(hand)
    mostChars = charCounts[max(charCounts,key=charCounts.get)]
    distinctChars = len(charCounts)
    if mostChars == 5:
        return "fiveOfAKind"
    if mostChars == 4:
        return "fourOfAKind"
    if mostChars == 3:
        if distinctChars == 2:
            return "fullHouse"
        else:
            return "threeOfAKind"
    if mostChars == 2:
        if distinctChars == 3:
            return "twoPair"
        if distinctChars == 4:
            return "pair"
    else:
        return "highCard"
    
    pass

def handKey(hand):
    k = 0
    k += typeStrengths[hand[2]]
    for i in range(5):
        k *= 100
        k += cardStrength[hand[0][i]]
    return k


def part1():
    with open("input.txt") as data:
        hands = []
        for h in data:
            h = h.split(" ")
            x = charCount(h[0])
            hands.append([h[0],int(h[1]),typeClassifier(h[0])])
            hands[-1].append(handKey(hands[-1]))
        
        # sort hands by hands[3]
       
        hands.sort(key=lambda x: x[3])
        score = 0
        for i,h in enumerate(hands):
            score += (i+1) * h[1]
        print(score)
        
            
        
part1()
