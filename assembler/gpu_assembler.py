import sys
import os


def reg_check(regs):
    for reg in regs:
        if reg not in registers:
            sys.exit(f'Invalid Register {reg}...')


def rtor_log_func(keywords, opcode):
    rd      = keywords[1]
    rs1     = keywords[2]
    func    = rtor_log[keywords[0]]
    reg_check([rd, rs1])
    if keywords[0] in ['not', 'NOT']:
        rs2 = 'rx0'
    else:
        rs2 = keywords[3]
    code = opcode << 27 | registers[rd] << 22 | registers[rs1] << 17 | registers[rs2] << 12 | func << 8
    return hex(code)


def imm_log_func(keywords, opcode):
    rd      = keywords[1]
    rs1     = keywords[2]
    func    = imm_log[keywords[0]]
    reg_check([rd, rs1])
    imm     = int(keywords[3]) & 0xFFF
    imm_hi  = (imm >> 8) & 0x1F
    imm_lo  = imm & 0xFF
    code    = opcode << 27 | registers[rd] << 22 | registers[rs1] << 17 | imm_hi << 12 | func << 8 | imm_lo
    return hex(code)


def reg_arith_func(keywords, opcode):
    rd      = keywords[1]
    rs1     = keywords[2]
    rs2     = keywords[3]
    func    = reg_arith[keywords[0]]
    reg_check([rd, rs1, rs2])
    code    = opcode << 27 | registers[rd] << 22 | registers[rs1] << 17 | registers[rs2] << 12 | func << 8
    return hex(code)


def imm_arith_func(keywords, opcode):
    if keywords[0] in ['nop', 'NOP']:
        rd  = 'rx0'
        rs1 = 'rx0'
        reg_check([rd, rs1])
        imm = 0
    else:
        rd  = keywords[1]
        rs1 = keywords[2]
        reg_check([rd, rs1])
        imm = int(keywords[3]) & 0xFFF
    func    = imm_arith[keywords[0]]
    imm_hi  = (imm >> 8) & 0x1F
    imm_lo  = imm & 0xFF
    code    = opcode << 27 | registers[rd] << 22 | registers[rs1] << 17 | imm_hi << 12 | func << 8 | imm_lo
    return hex(code)


def ld_ops_func(keywords, opcode):
    rd      = keywords[1]
    rs1     = keywords[2]
    func    = ld_ops[keywords[0]]
    reg_check([rd, rs1])
    if keywords[0] in ['mov', 'MOV']:
        imm = 0
    else:
        imm = int(keywords[3]) & 0xFFF
    imm_hi  = (imm >> 8) & 0x1F
    imm_lo  = imm & 0xFF
    code    = opcode << 27 | registers[rd] << 22 | registers[rs1] << 17 | imm_hi << 12 | func << 8 | imm_lo
    return hex(code)


def store_func(keywords, opcode):
    rs1     = keywords[2]
    rs2     = keywords[1]
    func    = store[keywords[0]]
    reg_check([rs2, rs1])
    imm     = int(keywords[3]) & 0xFFF
    code    = opcode << 27 | registers[rs1] << 17 | registers[rs2] << 12 | func << 8 | (imm & 0xFF)
    return hex(code)


def br_ctrl_func(keywords, opcode):
    rd      = keywords[1]
    reg_check([rd])
    func    = br_ctrl[keywords[0]]
    if keywords[0] in ['j', 'J']:
        imm     = int(keywords[1]) & 0xFFF
        imm_hi  = (imm >> 8) & 0x1F
        imm_lo  = imm & 0xFF
        code    = opcode << 27 | imm_hi << 12 | func << 8 | imm_lo
    else:
        code    = opcode << 27 | rd << 22
    return hex(code)


def rtor_cmp_func(keywords, opcode):
    rs1     = keywords[1]
    rs2     = keywords[2]
    func    = rtor_cmp[keywords[0]]
    reg_check([rs2, rs1])
    code    = opcode << 27 | registers[rs1] << 17 | registers[rs2] << 12 | func << 8
    return hex(code)


def imm_cmp_func(keywords, opcode):
    rs1     = keywords[1]
    reg_check([rs1])
    func    = imm_cmp[keywords[0]]
    imm     = int(keywords[2]) & 0xFFF
    imm_hi  = (imm >> 8) & 0x1F
    imm_lo  = imm & 0xFF
    code    = opcode << 27 | registers[rs1] << 17 | imm_hi << 12 | func << 8 | imm_lo
    return hex(code)


def mask_func(keywords, opcode):
    if keywords[0] in ['maskrst', 'MASKRST']:
        return hex(opcode << 27 | mask[keywords[0]] << 8)
    else:
        func    = mask[keywords[0]]
        imm     = int(keywords[1]) & 0xFFF
        imm_hi  = (imm >> 8) & 0x1F
        imm_lo  = imm & 0xFF
        code    = opcode << 27 | imm_hi << 12 | func << 8 |  imm_lo
        return hex(code)


def sys_ops_func(keywords, opcode):
    
    func = sys_ops[keywords[0]]
    if keywords[0] in ['cmov', 'CMOV']:
        rd      = keywords[1]
        rs1     = keywords[2]
        rs2     = keywords[3]
        reg_check([rd, rs1, rs2])
        mask_val = int(keywords[4])
        code    = opcode << 27 | registers[rd] << 22 | registers[rs1] << 17 | registers[rs2] << 12 | func << 8 | mask_val
        return hex(code)
        
    elif keywords[0] in ['glid', 'GLID']:
        rd      = keywords[1]
        reg_check([rd])
        code    = opcode << 27 | registers[rd] << 22 | func << 8
        return hex(code)

    elif keywords[0] in ['atomadd', 'ATOMADD']:
        rs1     = keywords[2]
        reg_check([rs1])
        imm     = int(keywords[1].replace("[","").replace("]",""), 16) & 0xFFF
        imm_hi  = (imm >> 8) & 0x1F
        imm_lo  = imm & 0xFF
        code    = opcode << 27 | registers[rs1] << 17 | imm_hi << 12 | func << 8 | imm_lo
        return hex(code)

    elif keywords[0] in ['redadd', 'REDADD']:
        rd      = keywords[1]
        rs1     = keywords[2]
        reg_check([rd, rs1])
        code    = opcode << 27 | registers[rd] << 22 | registers[rs1] << 17 | func << 8
        return hex(code)


def ext_end_func(keywords, opcode):
    func = ext_end[keywords[0]]
    code = opcode << 27 | func << 8
    return hex(code)


rtor_log = {
    'not': 0b0000,
    'and': 0b0001,
    'or':  0b0010,
    'xor': 0b0011,
    'shl': 0b1001,
    'shr': 0b1010,
    'rotl':0b1101,
    'rotr':0b1110
}

imm_log = {
    'andi': 0b0001,
    'ori':  0b0010,
    'xori': 0b0011,
    'sli':  0b1001,
    'sri':  0b1010
}

reg_arith = {
    'add': 0b0000,
    'sub': 0b0001,
    'mul': 0b0010,
    'div': 0b0011
}

imm_arith = {
    'nop':  0b1000,
    'addi': 0b1000,
    'subi': 0b1001
}

ld_ops = {
    'ld':  0b0001,
    'li':  0b0010,
    'mov': 0b0100
}

store = {
    'st': 0b0001
}

br_ctrl = {
    'bz':  0b0001,
    'bnz': 0b0010,
    'j':   0b0100
}

rtor_cmp = {
    'clt': 0b0001,
    'ceq': 0b0010
}

imm_cmp = {
    'clti': 0b1001,
    'ceqi': 0b1010
}

mask = {
    'maskrst': 0b0001,
    'mask':    0b0010
}

sys_ops = {
    'cmov':    0b0001,
    'glid':    0b0010,
    'atomadd': 0b0100,
    'redadd':  0b1000
}

ext_end = {
    'exit': 0b0001,
    'end':  0b0010
}


registers = {
    "rx0":  0b00000, "rx16": 0b10000,
    "rx1":  0b00001, "rx17": 0b10001,
    "rx2":  0b00010, "rx18": 0b10010,
    "rx3":  0b00011, "rx19": 0b10011,
    "rx4":  0b00100, "rx20": 0b10100,
    "rx5":  0b00101, "rx21": 0b10101,
    "rx6":  0b00110, "rx22": 0b10110,
    "rx7":  0b00111, "rx23": 0b10111,

    "rx8":  0b01000, "rx24": 0b11000,
    "rx9":  0b01001, "rx25": 0b11001,
    "rx10": 0b01010, "rx26": 0b11010,
    "rx11": 0b01011, "rx27": 0b11011,
    "rx12": 0b01100, "rx28": 0b11100,
    "rx13": 0b01101, "rx29": 0b11101,
    "rx14": 0b01110, "rx30": 0b11110,
    "rx15": 0b01111, "rx31": 0b11111    
}


types = {
    "rtor_log":  {'opcode': 0b00001, 'type': rtor_log,   'func': rtor_log_func},
    "imm_log":   {'opcode': 0b00010, 'type': imm_log,    'func': imm_log_func},
    "reg_arith": {'opcode': 0b00011, 'type': reg_arith,  'func': reg_arith_func},
    "imm_arith": {'opcode': 0b00011, 'type': imm_arith,  'func': imm_arith_func},
    "ld_ops":    {'opcode': 0b00100, 'type': ld_ops,     'func': ld_ops_func},
    "store":     {'opcode': 0b00110, 'type': store,      'func': store_func},
    "br_ctrl":   {'opcode': 0b00101, 'type': br_ctrl,    'func': br_ctrl_func},
    "rtor_cmp":  {'opcode': 0b00111, 'type': rtor_cmp,   'func': rtor_cmp_func},
    "imm_cmp":   {'opcode': 0b00111, 'type': imm_cmp,    'func': imm_cmp_func},
    "mask":      {'opcode': 0b01000, 'type': mask,       'func': mask_func},
    "sys_ops":   {'opcode': 0b01001, 'type': sys_ops,    'func': sys_ops_func},
    "ext_end":   {'opcode': 0b11111, 'type': ext_end,    'func': ext_end_func}
}

def encode_type_sel(keywords):
    for i in types.keys():
        if keywords[0] in types[i]['type']:
            code = types[i]['func'](keywords, types[i]['opcode'])
            return code
    sys.exit(f"No keyword '{keywords[0]}' found...")


instr = ['not', 'and', 'or', 'xor', 'shl', 'shr', 'rotl', 'rotr', 'andi', 'ori', 'xori', 'sli', 'sri', 
        'add', 'sub', 'mul', 'div', 'nop', 'addi', 'subi', 
        'ld', 'li', 'mov', 
        'st', 
        'bz', 'bnz', 'j', 
        'clt', 'ceq', 'clti', 'ceqi', 
        'maskrst', 'mask', 
        'cmov', 'glid', 'atomadd', 'redadd', 
        'exit', 'end']


def parser(line):
    line = line.split('#')[0].strip()
    if not line:
        return None
    return line.lower().replace(",", "").split()


hexcodes = []

with open('program.asm', 'r') as file:
    for line in file:
        line = line.replace(",", "")
        keywords = parser(line)
        if keywords == None:
            pass
        else:
            hexcodes.append(encode_type_sel(keywords))


with open(os.path.join(os.path.dirname(os.getcwd()), 'hex/gpu_imem.hex'), 'w') as ifile:
    for i in hexcodes:
        ifile.write(f"{i}\n")
        