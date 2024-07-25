var cpu = CPU()

let instructions = [
    0x11100293, // li t0, 0x111          addi x5, x0, 0x111
    0x22200313, // li t1, 0x222          addi x6, x0, 0x222
    0x628533,   // add a0, t0, t1        add x10, x5, x6
    0x293,      // li t0, 0              addi x5, x0, 0
    0x2a2a623,  // sw a0, 44(t0)         sw x10, 44(x5)
    0x2c2a303,  // lw t1, 44(t0)         lw x6, 44(x5)
    0x33300393, // li t2, 0x333          addi x7, x0, 0x333      tips: 修改t2的值0x333，使其不等于t1，以演示无条件跳转循环
    0x730663,   // beq t1, t2, 12        beq x6, x7, 12
    0x128293,   // addi t0, t0, 1        addi x5, x5, 1
    0xffdff06f  // jal x0, -4            jal x0, -4
]
for i in 0..<instructions.count {
    cpu.memory[i] = instructions[i]
}

while true {
    cpu.up()
    
    print("pc: \(cpu.programCounter >> 2)")
    for i in 0..<12 {
        if i & 1 == 0 {
            print(String(cpu.memory[i], radix: 16), terminator: " ")
        } else {
            print(String(cpu.memory[i], radix: 16))
        }
    }
    for i in 0..<11 {
        print("x\(i): \(String(cpu.registers[i], radix: 16))", terminator: " ")
    }
    print()
    print("----")
}
