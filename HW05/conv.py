import numpy as np

# random
# --------------------------------------------------
seed = 904
np.random.seed(int(seed))

# open file
# --------------------------------------------------
inf = open("input.txt", mode="w")
outf = open("output.txt", mode="w")

# param
# --------------------------------------------------

# var
# --------------------------------------------------
cvx = np.array([0, 0, 0, 0, 0])
cvy = np.array([0, 0, 0, 0, 0])
input = np.zeros([8, 8], dtype=int)

# function
# --------------------------------------------------

def printArr(arr, destifile, vertical = 0):
    for i in range(arr.size):
        destifile.write("{0:2d} ".format(arr[i]))
        if(vertical == 1):
            destifile.write("\n")
    destifile.write("\n")
    if(vertical == 0):
        destifile.write("\n")
    return

def printMat(mat, destifile):
    s = mat.shape
    for i in range(s[1]):
        for j in range(s[0]):
            destifile.write("{0:6d} ".format(mat[i][j]))
        destifile.write("\n")
    destifile.write("\n")
    return

def custom(convx, convy, pic, check = 0):
    c1 = np.zeros([8, 4], dtype=int)
    c2 = np.zeros([4, 4], dtype=int)
    for i in range(8):
        c1[i] = np.convolve(pic[i], np.flip(convx), mode='valid')
    for i in range(4):
        c2[i] = np.convolve(c1.T[i], np.flip(convy), mode='valid')
    result = c2.T
    if(check == 1):
        print("\nfilter 1: ")
        print(convx)
        print("\nfilter 2: ")
        print(convy)
        print("\nin_data: ")
        print(pic)
        print("\nafter convolution 1: ")
        print(c1)
        print("\nout_data: ")
        print(result)
    printArr(convx, inf, 0)
    printArr(convy, inf, 1)
    printMat(pic, inf)
    printMat(result, outf)
    return

def auto(check = 0):
    convx = np.random.randint(-8, 8, 5, dtype=int)
    convy = np.random.randint(-8, 8, 5, dtype=int)
    pic = np.random.randint(-8, 7, [8, 8], dtype=int)
    c1 = np.zeros([8, 4], dtype=int)
    c2 = np.zeros([4, 4], dtype=int)
    for i in range(8):
        c1[i] = np.convolve(pic[i], np.flip(convx), mode='valid')
    for i in range(4):
        c2[i] = np.convolve(c1.T[i], np.flip(convy), mode='valid')
    result = c2.T
    if(check == 1):
        print("\nfilter 1: ")
        print(convx)
        print("\nfilter 2: ")
        print(convy)
        print("\nin_data: ")
        print(pic)
        print("\nafter convolution 1: ")
        print(c1)
        print("\nout_data: ")
        print(result)
    printArr(convx, inf, 0)
    printArr(convy, inf, 1)
    printMat(pic, inf)
    printMat(result, outf)
    return

# pattern gen
# --------------------------------------------------
# if check = 1: print the data after first convolution
# default: check = 0
inf.write("500\n\n")
# pat1
custom(cvx, cvy, input, check = 0)
# pat2
cvx = np.array([-8, -8, -8, -8, -8])
cvy = np.array([-8, -8, -8, -8, -8])
input = np.ones([8, 8], dtype=int)*-8
custom(cvx, cvy, input,  check = 1)
# pat3
cvx = np.array([7, 7, 7, 7, 7])
cvy = np.array([7, 7, 7, 7, 7])
input = np.ones([8, 8], dtype=int)*7
custom(cvx, cvy, input)
# pat auto
auto(check = 0)
auto()
auto()
auto()
auto()
auto()
auto()
for i in range(490):
    auto()

# close file
# --------------------------------------------------
inf.close()
outf.close()
