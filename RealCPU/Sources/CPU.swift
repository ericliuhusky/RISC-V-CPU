struct ProgramCounter {
    var register = Register()
    
    mutating func up(data: Data, set: Bit, clock: Bit) {
        let sum = adder(a: register.q, b: Data(4), carry: Bit(0)).sum
        let data = multiplexer(select: [set], input: [sum, data])
        register.up(data: data, writeEnable: Bit(1), clock: clock)
    }
    
    var q: Data {
        register.q
    }
}

struct RegisterFile {
    static let zero = Data(repeating: Bit(0), count: 32)
    var registers = [Register](repeating: Register(), count: 31)
    
    mutating func up(data: Data, rd: Data, clock: Bit) {
        let writeEnableArray = decoder(select: rd)
        for i in 0..<31 {
            registers[i].up(data: data, writeEnable: writeEnableArray[i + 1], clock: clock)
        }
    }
    
    func q1(rs1: Data) -> Data {
        multiplexer(select: rs1, input: [Self.zero] + registers.map { $0.q })
    }
    
    func q2(rs2: Data) -> Data {
        multiplexer(select: rs2, input: [Self.zero] + registers.map { $0.q })
    }
}

struct ControlUnit {
    var instruction: Data
    var branchEqual: Bit
    
    var opcode: Data {
        Data(instruction[0...6])
    }
    
    var opType: Data {
        multiplexer(select: [opcode[6]], input: [Data(opcode[4...6]), Data(opcode[3...5])])
    }
    
    var rd: Data {
        Data(instruction[7...11])
    }
    
    var rs1: Data {
        Data(instruction[15...19])
    }
    
    var rs2: Data {
        Data(instruction[20...24])
    }
    
    var immediate: Data {
        let inst = instruction
        let iTypeImmediate = Data(inst[20...31]) + Data(repeating: Bit(0), count: 20)
        let sTypeImmediate = Data(inst[7...11]) + Data(inst[25...31]) + Data(repeating: Bit(0), count: 20)
        let rTypeImmediate = Data(repeating: Bit(0), count: 32)
        let bTypeImmediate = [Bit(0)] + Data(inst[8...11]) + Data(inst[25...30]) + [inst[7], inst[31]] + Data(repeating: inst[31], count: 19)
        let jTypeImmediate = [Bit(0)] + Data(inst[21...30]) + [inst[20]] + Data(inst[12...19]) + [inst[31]] + Data(repeating: inst[31], count: 11)
        return multiplexer(select: opType, input: [iTypeImmediate, iTypeImmediate, sTypeImmediate, rTypeImmediate, bTypeImmediate, jTypeImmediate])
    }
    
    var isALURType: Bit {
        and(and(opType[0], opType[1]), not(opType[2]))
    }
    
    var isLoadIType: Bit {
        and(and(not(opType[0]), not(opType[1])), not(opType[2]))
    }
    
    var isStoreType: Bit {
        and(and(not(opType[0]), opType[1]), not(opType[2]))
    }
    
    var isBranchType: Bit {
        and(and(not(opType[0]), not(opType[1])), opType[2])
    }
    
    var isJumpType: Bit {
        and(and(opType[0], not(opType[1])), opType[2])
    }
    
    var immediateSelect: Bit {
        not(isALURType)
    }
    
    var loadSelect: Bit {
        isLoadIType
    }
    
    var storeSelect: Bit {
        isStoreType
    }
    
    var setPCSelect: Bit {
        or(and(isBranchType, branchEqual), isJumpType)
    }
}

struct CPU {
    var pc = ProgramCounter()
    var ram = RAM()
    var registerFile = RegisterFile()
    
    mutating func up(clock: Bit) {
        let instruction = ram.data(address: pc.q, readEnable: Bit(1))
        var controlUnit = ControlUnit(instruction: instruction, branchEqual: Bit(0))
        let q1 = registerFile.q1(rs1: controlUnit.rs1)
        let q2 = registerFile.q2(rs2: controlUnit.rs2)
        let branchEqual = Bit(q1 == q2)
        controlUnit.branchEqual = branchEqual
        let a = multiplexer(select: [controlUnit.setPCSelect], input: [q1, pc.q])
        let b = multiplexer(select: [controlUnit.immediateSelect], input: [q2, controlUnit.immediate])
        let sum = adder(a: a, b: b, carry: Bit(0)).sum
        let loadData = ram.data(address: sum, readEnable: controlUnit.loadSelect)
        let data = multiplexer(select: [controlUnit.loadSelect], input: [sum, loadData])
        ram.up(address: sum, data: q2, writeEnable: controlUnit.storeSelect, clock: clock)
        registerFile.up(data: data, rd: controlUnit.rd, clock: clock)
        pc.up(data: sum, set: controlUnit.setPCSelect, clock: clock)
        
        if instruction.number == 0 {
            exit(0)
        }
    }
}
