import numpy as np
from random import random, randint
maxEpisodes = 500
startY = 5
startX = 0

maxState = 4
UP = 0
DOWN = 1
RIGHT = 2
LEFT = 3

alpha = 0.5
gamma = 1.0
epsilon = 0.1

maxVertical = 7
maxHorizontal = 10

wallY = 3
wallX = [8, 9]

goalY = 1
goalX = 4


POLICY = True
VALUES = False

def inWall(x, y):
    return y == wallY and (x not in wallX)

Q = np.zeros(shape=(maxVertical, maxHorizontal, maxState))
for epoch in range (maxEpisodes):
    y = startY                   
    x = startX
    terminal = 0

    if random() > epsilon:
        action = np.argmax(Q[y, x, :])
    else:
        action = randint(0, maxState-1)
    

    while (terminal != 1):
        reward = -1
        if action == UP:
            next_y = y - 1
            next_x = x
            if next_y < 0:
                next_y = y

        elif action == DOWN:
            next_y = y + 1
            next_x = x
            if next_y >= maxVertical:
                next_y = y
        
        elif action == LEFT:
            next_y = y
            next_x = x - 1
            if next_x < 0:
                next_x = x

        elif action == RIGHT:
            next_y = y
            next_x = x + 1
            if next_x >= maxHorizontal:
                next_x = x
        else:
            print("INVALID ACTION")

        if inWall(next_x, next_y):
            # print(f"inwall because nextX={next_x} nextY={next_y}. Staying in x={x}, y={y}")
            next_y = y
            next_x = x
        
        if random() > epsilon:
            next_action = np.argmax(Q[next_y, next_x, :])
        else:
            next_action = randint(0, maxState-1)
        # do reward shit
        
        if ((next_y == goalY) and (next_x == goalX)):
            terminal = 1
        
        Q[y,x,action] = Q[y,x,action] + (alpha * (reward + (gamma * Q[next_y,next_x,next_action]) - Q[y,x,action]))

        action = next_action
        y = next_y
        x = next_x

if (POLICY):
    Policy = [["" for i in range(maxHorizontal)] for j in range(maxVertical)]

    for y in range(maxVertical):
        for x in range(maxHorizontal):
            if inWall(x, y):
                Policy[y][x] = "WALL"
                continue
            if x == goalX and y == goalY:
                Policy[y][x] = "GOAL"
                continue
            if x == startX and y == startY:
                Policy[y][x] = "START"
                continue
            action = np.argmax(Q[y,x,:])
            if action == UP:
                Policy[y][x] = "UP"
            elif action == DOWN:
                Policy[y][x] = "DOWN"
            elif action == LEFT:
                Policy[y][x] = "LEFT"
            elif action == RIGHT:
                Policy[y][x] = "RIGHT"  			
            else:
                print('Invalid action in policy')

    for row in Policy:
        output = "\t".join([str(cell) for cell in row])
        print(output)

if VALUES:
    labels = ["UP", "DOWN", "RIGHT", "LEFT"]
    Q = Q.round(decimals=3)
    for i, label in enumerate(labels):
        print()
        print(label)
        for row in Q[:, :, i]:
            output = "\t".join([str(cell) for cell in row])
            print(output)