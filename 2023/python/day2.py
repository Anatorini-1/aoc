import os
rgb = {
    "r": 12,
    "g": 13,
    "b": 14
}

os.system("clear")
with open("day2data.txt") as games:
    sum = 0
    s2 = 0
    s3 = 0
    for game in games:
        isValid = True
        game_id = int(game.split(":")[0].split(" ")[1])
        print(game)
        rounds = game.split(":")[1].split(";")
        for round in rounds:
            draws = [x.strip().split(" ") for x in round.split(",")]
          #  print(draws)
            for draw in draws:
                if int(draw[0]) > rgb[draw[1][0]]:
                    isValid = False
                    #print("invalid, "+draw[1]+draw[0]+" > "+str(rgb[draw[1][0]]))
        if isValid:
            sum += game_id
    print(sum)


with open("day2data.txt") as games:
    sum = 0

    for game in games:
        isValid = True
        minRGB = {
            "r": 0,
            "g": 0,
            "b": 0
        }
        game_id = int(game.split(":")[0].split(" ")[1])
        print(game)
        rounds = game.split(":")[1].split(";")
        for round in rounds:
            draws = [x.strip().split(" ") for x in round.split(",")]
            for draw in draws:
                if int(draw[0]) > minRGB[draw[1][0]]:
                    minRGB[draw[1][0]] = int(draw[0])
        sum += int(minRGB['r'])*int(minRGB['g'])*int(minRGB['b'])
    print(sum)