import random
import string

#random
#--------------------------------------------------
seed = 904
random.seed(int(seed))

#open file
#--------------------------------------------------
inf = open("input.txt", mode = "w")
outf = open("output.txt", mode = "w")

#param
#--------------------------------------------------
addr = ["10001","10010","01000","10111","11111","10000"]
opcode = {'arith':'000000','imm':'001000'}
funct = {'add':'100000', 'and':'100100', 'or':'100101', 'nor':'100111', 'shleft':'000000', 'shright':'000010'}
opcode_list = ['000000','001000']
funct_list = ['100000','100100','100101','100111','000000','000010']
funct_name = ['add','and','or','nor','shleft','shright']

#var
#--------------------------------------------------
reg = [0,0,0,0,0,0]

#function
#--------------------------------------------------
def DTB(n):
    return bin(n).replace("0b", "")

def BTD(val):
    return int(val, 2) 

def bit_not(n, numbits=32):
    return (1 << numbits) - 1 - n

def NOP():
    #in
    inf.write("00000000000000000000000000000000 ");
    inf.write("10001100011000110001\n");
    #out
    outf.write("1 ")
    outf.write("{0:10d} ".format(0))
    outf.write("{0:10d} ".format(0))
    outf.write("{0:10d} ".format(0))
    outf.write("{0:10d}\n".format(0))
    return
    
def R_type(reg1, reg2, reg_desti, shamt, f, optional_reg):
    #in
    shamt_string = str(DTB(shamt))
    length0 = 5 - len(shamt_string)
    for i in range(length0):
        shamt_string = '0' + shamt_string
    instruction = opcode['arith']+addr[reg1]+addr[reg2]+addr[reg_desti]+shamt_string+funct[f]
    output_reg = addr[reg1]+addr[reg2]+addr[reg_desti]+addr[optional_reg]
    inf.write(instruction + ' ' + output_reg + '\n')
    #out
    if f == 'add':
        out_bus = (reg[reg1] + reg[reg2])%(2**32)
    elif f == 'and':
        out_bus = int(reg[reg1]) & int(reg[reg2])
    elif f == 'or':
        out_bus = int(reg[reg1]) | int(reg[reg2])
    elif f == 'nor':
        out_bus = bit_not(reg[reg1] | reg[reg2])
    elif f == 'shleft':
        out_bus = (reg[reg2] << shamt)%(2**32)
    elif f == 'shright':
        out_bus = reg[reg2] >> shamt
    reg[reg_desti] = out_bus
    outf.write("0 ")
    outf.write("{0:10d} ".format(reg[optional_reg]))
    outf.write("{0:10d} ".format(reg[reg_desti]))
    outf.write("{0:10d} ".format(reg[reg2]))
    outf.write("{0:10d}\n".format(reg[reg1]))
    return 

def I_type(reg1, reg_desti, imm, optional_regs):
    #in
    imm_string = str(DTB(imm))
    length0 = 16 - len(imm_string)
    for i in range(length0):
        imm_string = '0' + imm_string
    instruction = opcode['imm']+addr[reg1]+addr[reg_desti]+imm_string
    output_reg = addr[reg1]+addr[reg_desti]+addr[optional_regs[0]]+addr[optional_regs[1]]
    inf.write(instruction + ' ' + output_reg + '\n')
    #out
    reg[reg_desti] = (reg[reg1] + imm)%(2**32)
    outf.write("0 ")
    outf.write("{0:10d} ".format(reg[optional_regs[1]]))
    outf.write("{0:10d} ".format(reg[optional_regs[0]]))
    outf.write("{0:10d} ".format(reg[reg_desti]))
    outf.write("{0:10d}\n".format(reg[reg1]))
    return

def error_R_type(op_b, reg1_addr, reg2_addr, reg_desti_addr, shamt, f_b, regs):
    #in
    shamt_string = str(DTB(shamt))
    length0 = 5 - len(shamt_string)
    for i in range(length0):
        shamt_string = '0' + shamt_string
    instruction = op_b+reg1_addr+reg2_addr+reg_desti_addr+shamt_string+f_b
    output_reg = addr[regs[0]]+addr[regs[1]]+addr[regs[2]]+addr[regs[3]]
    inf.write(instruction + ' ' + output_reg + '\n')
    #out
    outf.write("1 ")
    outf.write("{0:10d} ".format(0))
    outf.write("{0:10d} ".format(0))
    outf.write("{0:10d} ".format(0))
    outf.write("{0:10d}\n".format(0))
    return
    
def error_I_type(op_b, reg1_addr, reg2_addr, imm, regs):
    #in
    imm_string = str(DTB(imm))
    length0 = 16 - len(imm_string)
    for i in range(length0):
        imm_string = '0' + imm_string
    instruction = op_b+reg1_addr+reg2_addr+imm_string
    output_reg = addr[regs[0]]+addr[regs[1]]+addr[regs[2]]+addr[regs[3]]
    inf.write(instruction + ' ' + output_reg + '\n')
    #out
    outf.write("1 ")
    outf.write("{0:10d} ".format(0))
    outf.write("{0:10d} ".format(0))
    outf.write("{0:10d} ".format(0))
    outf.write("{0:10d}\n".format(0))
    return

def error_R_type_auto(op_e, reg1_e, reg2_e, reg_desti_e, f_e):
    #in
    #shamt
    shamt_str = DTB(random.randint(0,31))
    length0 = 5 - len(shamt_str)
    for i in range(length0):
        shamt_str = '0' + shamt_str
    #opcode
    if op_e == 1:
        op_str = ''.join(random.choice(['0','1']) for x in range(6))
        while op_str in opcode_list:
            op_str = ''.join(random.choice(['0','1']) for x in range(6))
    else:
        op_str = opcode_list[0]
    #reg1
    if reg1_e == 1:
        reg1_str = ''.join(random.choice(['0','1']) for x in range(5))
        while reg1_str in set(addr):
            reg1_str = ''.join(random.choice(['0','1']) for x in range(5))
    else:
        reg1_str = addr[random.randint(0,5)]
    #reg2
    if reg2_e == 1:
        reg2_str = ''.join(random.choice(['0','1']) for x in range(5))
        while reg2_str in set(addr):
            reg2_str = ''.join(random.choice(['0','1']) for x in range(5))
    else:
        reg2_str = addr[random.randint(0,5)]
    #reg2
    if reg_desti_e == 1:
        reg_desti_str = ''.join(random.choice(['0','1']) for x in range(5))
        while reg_desti_str in set(addr):
            reg_desti_str = ''.join(random.choice(['0','1']) for x in range(5))
    else:
        reg_desti_str = addr[random.randint(0,5)]
    #funct
    if f_e == 1:
        f_str = ''.join(random.choice(['0','1']) for x in range(6))
        while f_str in set(funct_list):
            f_str = ''.join(random.choice(['0','1']) for x in range(6))
    else:
        f_str = funct_list[random.randint(0,5)]
    instruction = op_str+reg1_str+reg2_str+reg_desti_str+shamt_str+f_str
    output_reg = addr[random.randint(0,5)]+addr[random.randint(0,5)]+addr[random.randint(0,5)]+addr[random.randint(0,5)]
    inf.write(instruction + ' ' + output_reg + '\n')
    #out
    outf.write("1 ")
    outf.write("{0:10d} ".format(0))
    outf.write("{0:10d} ".format(0))
    outf.write("{0:10d} ".format(0))
    outf.write("{0:10d}\n".format(0))
    return

def error_I_type_auto(op_e, reg1_e, reg_desti_e):
    #in
    #opcode
    if op_e == 1:
        op_str = ''.join(random.choice(['0','1']) for x in range(6))
        while op_str in opcode_list:
            op_str = ''.join(random.choice(['0','1']) for x in range(6))
    else:
        op_str = opcode_list[1]
    #reg1
    if reg1_e == 1:
        reg1_str = ''.join(random.choice(['0','1']) for x in range(5))
        while reg1_str in set(addr):
            reg1_str = ''.join(random.choice(['0','1']) for x in range(5))
    else:
        reg1_str = addr[random.randint(0,5)]
    #reg2
    if reg_desti_e == 1:
        reg_desti_str = ''.join(random.choice(['0','1']) for x in range(5))
        while reg_desti_str in set(addr):
            reg_desti_str = ''.join(random.choice(['0','1']) for x in range(5))
    else:
        reg_desti_str = addr[random.randint(0,5)]
    imm_str = DTB(random.randint(0,65535))
    length0 = 16 - len(imm_str)
    for i in range(length0):
        imm_str = '0' + imm_str
    instruction = op_str+reg1_str+reg_desti_str+imm_str
    output_reg = addr[random.randint(0,5)]+addr[random.randint(0,5)]+addr[random.randint(0,5)]+addr[random.randint(0,5)]
    inf.write(instruction + ' ' + output_reg + '\n')
    #out
    outf.write("1 ")
    outf.write("{0:10d} ".format(0))
    outf.write("{0:10d} ".format(0))
    outf.write("{0:10d} ".format(0))
    outf.write("{0:10d}\n".format(0))
    return

#cpu computation functions
#--------------------------------------------------
#reg5: 0
#cost 6
def Clean_all_regs():
    I_type(5,0,0,[0,0])
    I_type(5,1,0,[0,0])
    I_type(5,2,0,[0,0])
    I_type(5,3,0,[0,0])
    I_type(5,4,0,[0,0])
    error_R_type_auto(0,1,0,0,0)
    return
#cost 2 ~ 6 (1 + len(regnums))
def Clean_regs(regnums):
    for regnum in regnums:
        I_type(5,regnum,0,[0,0])
    error_R_type_auto(0,0,1,0,0)
    return
#num1 + num2 to reg0 // using reg0 reg1 reg2
#cost 9
def ADD(num1, num2):
    Clean_regs([0,1,2]) #4
    I_type(5,1,num1,[2,3])
    I_type(5,2,num2,[2,3])
    error_R_type_auto(0,0,0,1,0)
    R_type(1,2,0,0,'add',3)
    error_R_type_auto(0,0,0,0,1)
    return
#num1 * num2 to reg0 // using reg0 reg1 reg2
#cost 9 + 5 * len(num2b)
def MUL(num1, num2):
    Clean_all_regs() #6
    I_type(5,1,num1,[0,2])
    error_R_type_auto(1,0,0,0,0)
    num2b = DTB(num2)
    for i in range(len(num2b)): #5 * len(num2b)
        if (num2b[len(num2b)-1-i] == '1'):
            R_type(random.randint(0,5),1,0,i,'shleft',5)
        else:
            R_type(random.randint(0,5),5,0,i,'shright',4)
        error_R_type_auto(0,1,0,0,0)
        R_type(0,3,4,random.randint(0,31),'add',random.randint(0,5))
        error_R_type_auto(0,0,1,0,0)
        R_type(4,5,3,random.randint(0,31),'or',random.randint(0,5))
    error_I_type("000000", "00000", "00000", 12345, [0,3,4,5])
    return 


#example
#--------------------------------------------------
'''
NOP() // instruction = 31'd0;
R_type(0,1,2,0,'nor',3) // rs = reg0 
I_type(0,1,1234,3)
error_R_type('010101','01010','01010','01010',12,'010101',[0,1,2,3])
error_I_type('010101','01010','01010',1234,[0,1,2,3])
error_R_type_auto(1,1,1,1,1)
error_I_type_auto(1,1,1)
Clean_all_regs() // 6
Clean_regs(regnums) // 1+len(regnums)
ADD(num1, num2) // 9
MUL(num1, num2) // 9 + 5 * len(num2:binary)
'''
#pattern gen
#--------------------------------------------------
cost = 36 + 216 + 10 + 11 + 100 + 1300 - 13
cost_str = str(cost)
inf.write(cost_str + '\n')
#immediate test cost: 11

I_type(0,1,10,[random.randint(0,5),random.randint(0,5)])
I_type(2,3,20,[random.randint(0,5),random.randint(0,5)])
I_type(0,2,30,[random.randint(0,5),random.randint(0,5)])
I_type(3,0,40,[random.randint(0,5),random.randint(0,5)])
I_type(4,2,50,[random.randint(0,5),random.randint(0,5)])
I_type(5,2,60,[random.randint(0,5),random.randint(0,5)])
I_type(3,2,70,[random.randint(0,5),random.randint(0,5)])
I_type(1,2,80,[random.randint(0,5),random.randint(0,5)])
I_type(0,2,90,[random.randint(0,5),random.randint(0,5)])
I_type(1,1,100,[random.randint(0,5),random.randint(0,5)])
I_type(0,0,110,[random.randint(0,5),random.randint(0,5)])
#arithmatic test cost: 10

R_type(3,1,2,random.randint(0,31),'nor',random.randint(0,5))
R_type(3,4,5,random.randint(0,31),'and',random.randint(0,5))
R_type(1,2,3,random.randint(0,31),'or',random.randint(0,5))
R_type(4,5,0,random.randint(0,31),'shright',random.randint(0,5))
R_type(2,3,4,random.randint(0,31),'add',random.randint(0,5))
R_type(5,0,1,random.randint(0,31),'and',random.randint(0,5))
R_type(3,4,5,random.randint(0,31),'nor',random.randint(0,5))
R_type(1,3,5,random.randint(0,31),'or',random.randint(0,5))
R_type(2,4,0,random.randint(0,31),'shleft',random.randint(0,5))
R_type(1,3,2,random.randint(0,31),'nor',random.randint(0,5))
#error test cost: 100
for i in range(10):
    error_R_type_auto(1,0,0,0,0)
    error_R_type_auto(0,1,0,0,0)
    error_R_type_auto(0,0,1,0,0)
    error_R_type_auto(0,0,0,1,0)
    error_R_type_auto(0,0,0,0,1)
    error_R_type_auto(1,1,1,1,1)
    error_I_type_auto(0,0,1)
    error_I_type_auto(0,1,0)
    error_I_type_auto(1,0,0)
    error_I_type_auto(1,1,1)
#random test cost: 2000
r1 = random.randint(0,5)
r2 = random.randint(0,5)
rd = random.randint(0,5)
for i in range(1000):
    if(random.randint(0,1) == 1):
        R_type(r1,r2,rd,random.randint(0,31),funct_name[random.randint(0,5)],random.randint(0,5))
    else:
        I_type(r1,rd,random.randint(0,65535),[random.randint(0,5),random.randint(0,5)])
    hazard_record = rd
    r1 = random.randint(0,5)
    r2 = random.randint(0,5)
    rd = random.randint(0,5)
    if (r1 == hazard_record) | (r2 == hazard_record):
        if(random.randint(0,1) == 1):
            error_R_type_auto(1,random.randint(0,1),random.randint(0,1),random.randint(0,1),random.randint(0,1))
        else:
            error_I_type_auto(1,random.randint(0,1),random.randint(0,1))
#hand test
error_R_type('100000',addr[random.randint(0,5)],addr[random.randint(0,5)],addr[random.randint(0,5)],10,funct_list[random.randint(0,5)],[0,1,2,3])
error_R_type('010000',addr[random.randint(0,5)],addr[random.randint(0,5)],addr[random.randint(0,5)],10,funct_list[random.randint(0,5)],[0,1,2,3])
error_R_type('000100',addr[random.randint(0,5)],addr[random.randint(0,5)],addr[random.randint(0,5)],10,funct_list[random.randint(0,5)],[0,1,2,3])
error_R_type('000010',addr[random.randint(0,5)],addr[random.randint(0,5)],addr[random.randint(0,5)],10,funct_list[random.randint(0,5)],[0,1,2,3])
error_R_type('000001',addr[random.randint(0,5)],addr[random.randint(0,5)],addr[random.randint(0,5)],10,funct_list[random.randint(0,5)],[0,1,2,3])
error_R_type('101000',addr[random.randint(0,5)],addr[random.randint(0,5)],addr[random.randint(0,5)],10,funct_list[random.randint(0,5)],[2,3,4,5])
error_R_type('011000',addr[random.randint(0,5)],addr[random.randint(0,5)],addr[random.randint(0,5)],10,funct_list[random.randint(0,5)],[2,3,4,5])
error_R_type('001100',addr[random.randint(0,5)],addr[random.randint(0,5)],addr[random.randint(0,5)],10,funct_list[random.randint(0,5)],[2,3,4,5])
error_R_type('001010',addr[random.randint(0,5)],addr[random.randint(0,5)],addr[random.randint(0,5)],10,funct_list[random.randint(0,5)],[2,3,4,5])
error_R_type('001001',addr[random.randint(0,5)],addr[random.randint(0,5)],addr[random.randint(0,5)],10,funct_list[random.randint(0,5)],[2,3,4,5])
error_I_type('100000',addr[random.randint(0,5)],addr[random.randint(0,5)],60000,[0,1,2,3])
error_I_type('010000',addr[random.randint(0,5)],addr[random.randint(0,5)],60000,[0,1,2,3])
error_I_type('000100',addr[random.randint(0,5)],addr[random.randint(0,5)],60000,[0,1,2,3])
error_I_type('000010',addr[random.randint(0,5)],addr[random.randint(0,5)],60000,[0,1,2,3])
error_I_type('000001',addr[random.randint(0,5)],addr[random.randint(0,5)],60000,[0,1,2,3])
error_I_type('101000',addr[random.randint(0,5)],addr[random.randint(0,5)],60000,[0,1,2,3])
error_I_type('011000',addr[random.randint(0,5)],addr[random.randint(0,5)],60000,[0,1,2,3])
error_I_type('001100',addr[random.randint(0,5)],addr[random.randint(0,5)],60000,[0,1,2,3])
error_I_type('001010',addr[random.randint(0,5)],addr[random.randint(0,5)],60000,[0,1,2,3])
error_I_type('001001',addr[random.randint(0,5)],addr[random.randint(0,5)],60000,[0,1,2,3])
R_type(1,0,3,16,'shright',random.randint(0,5))
R_type(2,0,4,16,'shleft',random.randint(0,5))
error_I_type_auto(1,random.randint(0,1),random.randint(0,1))
R_type(3,4,5,16,'and',random.randint(0,5))
error_I_type_auto(1,random.randint(0,1),random.randint(0,1))
Clean_all_regs()
#cpu ADD test cost: 9*4 = 36
ADD(34,23)
ADD(512,516)
ADD(9999,9999)
ADD(65535,65535)
#cpu MUL test cost: 216
MUL(1,1) #14
MUL(5,5) #24
MUL(170,170) #49
MUL(65535,65535) #89

#close file
#--------------------------------------------------
inf.close()
outf.close()
