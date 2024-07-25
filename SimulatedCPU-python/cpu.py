def i2b(n):
    t = list(map(int, bin(n)[2:][::-1]))
    return t + [0] * (32 - len(t))

def b2i(b):
    s = ''.join(list(map(str, b[::-1])))
    s = '0' if s == '' else s
    return int(s, 2)

def n_num(n):
    return -(int(''.join(list(map(lambda x: '0' if x == '1' else '1', bin(n)[2:]))), 2) + 1)

class ControlUnit:
    def __init__(self, inst):
        self.inst = i2b(inst)

    def opcode(self):
        op = self.inst[0:7]
        if op[6] == 0:
            return b2i(op[4:7])
        else:
            return b2i(op[3:6])

    def rd(self):
        return b2i(self.inst[7:12])

    def rs1(self):
        return b2i(self.inst[15:20])

    def rs2(self):
        return b2i(self.inst[20:25])

    def imi(self):
        op = self.opcode()
        if op == 0 or op == 1:
            return b2i(self.inst[20:32])
        elif op == 2:
            return b2i(self.inst[7:12] + self.inst[25:32])
        elif op == 3:
            return 0
        elif op == 4:
            t = b2i([0] + self.inst[8:12] + self.inst[25:31] + [self.inst[7], self.inst[31]])
            if self.inst[31] == 1:
                return n_num(t)
            return t
        elif op == 5:
            t = b2i([0] + self.inst[21:31] + [self.inst[20]] + self.inst[12:20] + [self.inst[31]])
            if self.inst[31] == 1:
                return n_num(t)
            return t

class CPU:
    def __init__(self):
        self.pc = 0
        self.regs = [0] * 32
        self.memo = [0] * 1024

    def up(self):
        inst = self.memo[self.pc >> 2]
        cu = ControlUnit(inst)
        rs1 = self.regs[cu.rs1()]
        rs2 = self.regs[cu.rs2()]
        a = rs1
        if cu.opcode() == 4 or cu.opcode() == 5:
            a = self.pc
        b = rs2
        if cu.opcode() != 3:
            b = cu.imi()
        s = a + b
        rd = s
        if cu.opcode() == 0:
            rd = self.memo[s >> 2]
        if cu.opcode() == 2:
            self.memo[s >> 2] = rs2
        self.regs[cu.rd()] = rd
        beq = rs1 == rs2
        self.pc += 4
        if (cu.opcode() == 4 and beq == True) or cu.opcode() == 5:
            self.pc = s
        
        if inst == 0:
            exit()
