'''
Job Assignment using Hungarian Algorithm
DCS Final
5/28/2022
'''
from array import array
from operator import index
from random import random
import numpy as np
import munkres as mk
import itertools

# random
# --------------------------------------------------
seed = 516904
np.random.seed(int(seed))

# open file
# --------------------------------------------------
inf = open("input.txt", mode="w")
outf = open("output.txt", mode="w")

# param
# --------------------------------------------------
n = 8

# var
# --------------------------------------------------

# function
# --------------------------------------------------


def RandM():
    return np.random.randint(0, 128, size=(n, n))


def HA(mat):
    matin = np.copy(mat)
    m = mk.Munkres()
    indexes = m.compute(matin)
    #mk.print_matrix(mat, msg='Lowest cost through this matrix:')
    total = 0
    for row, column in indexes:
        value = mat[row][column]
        total += value
        #print(f'({row}, {column}) -> {value}')
    #print(f'total cost: {total}')
    return mat, indexes, total


def BF(mat):
    matin = np.copy(mat)
    p_list = [0, 1, 2, 3, 4, 5, 6, 7]
    permutations = list(itertools.permutations(p_list))
    min = 99999
    min_comb = (0, 1, 2, 3, 4, 5, 6, 7)
    for comb in permutations:
        sum = matin[0][comb[0]] + matin[1][comb[1]] + \
            matin[2][comb[2]] + matin[3][comb[3]]
        sum += matin[4][comb[4]] + matin[5][comb[5]] + \
            matin[6][comb[6]] + matin[7][comb[7]]
        if sum < min:
            min = sum
            min_comb = comb
    indexes = [1, 2, 3, 4, 5, 6, 7, 8]
    for i in range(8):
        indexes[i] = min_comb[i]
    for i in range(n):
        for j in range(n):
            inf.write("{0:3d} ".format(mat[i][j]))
        inf.write("\n")
    inf.write("\n")
    for column in indexes:
        outf.write("{0:2d} ".format(column+1))
    outf.write("{0:5d} ".format(min))
    outf.write("\n")


def Auto():
    mat = RandM()
    mat, idx, cost = HA(mat)
    Sushi(mat, idx, cost)


def Hand(mat):
    mat, idx, cost = HA(mat)
    Sushi(mat, idx, cost)


def Sushi(mat, index, cost):
    for i in range(n):
        for j in range(n):
            inf.write("{0:3d} ".format(mat[i][j]))
        inf.write("\n")
    inf.write("\n")
    for row, column in index:
        outf.write("{0:2d} ".format(column+1))
    outf.write("{0:5d} ".format(cost))
    outf.write("\n")


# pattern gen
# --------------------------------------------------
matrix = np.zeros((n, n), dtype=int)

for k in range(10000):
    for i in range(8):
        for j in range(8):
            rdn = random()
            if(rdn > 0.875):
                matrix[i][j] = 0
            else:
                matrix[i][j] = 127
    BF(matrix)


'''
matrix = np.zeros((n, n), dtype=int)
Hand(matrix)
matrix = np.ones((n, n), dtype=int) * 50
Hand(matrix)
matrix = np.ones((n, n), dtype=int) * 127
Hand(matrix)
matrix = np.eye(n, dtype=int) * 127
Hand(matrix)
matrix = (np.eye(n, dtype=int, k=1) * 126) + 1
Hand(matrix)

matrix = RandM()
matrix[0][7] = 0
matrix[1][6] = 0
matrix[2][5] = 0
matrix[3][4] = 0
matrix[4][3] = 0
matrix[5][2] = 0
matrix[6][1] = 0
matrix[7][0] = 0
Hand(matrix)

matrix = RandM()
matrix[0][7] = 0
matrix[0][6] = 0
matrix[0][5] = 0
matrix[0][4] = 0
matrix[0][3] = 0
matrix[0][2] = 0
matrix[0][1] = 0
matrix[0][0] = 0
Hand(matrix)

matrix = RandM()
matrix[0][0] = 0
matrix[1][0] = 0
matrix[2][0] = 0
matrix[3][0] = 0
matrix[4][0] = 0
matrix[5][0] = 0
matrix[6][0] = 0
matrix[7][0] = 0
Hand(matrix)

matrix = RandM()
matrix[0][6:8] = 0
matrix[1][6:8] = 0
matrix[2][4:6] = 0
matrix[3][4:6] = 0
matrix[4][2:4] = 0
matrix[5][2:4] = 0
matrix[6][0:2] = 0
matrix[7][0:2] = 0
Hand(matrix)

matrix = RandM()
for i in range(8):
    for j in range(8):
        if(i+j == 3 or i+j == 11 or j - i == 4 or i - j == 4):
            matrix[i][j] = 0
Hand(matrix)
'''

# close file
# --------------------------------------------------
inf.close()
outf.close()
