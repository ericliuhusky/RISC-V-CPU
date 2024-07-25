extension Int {
    init(bits: [Int]) {
        var number = 0
        for i in 0..<bits.count {
            number <<= 1
            number |= bits[bits.count - i - 1]
        }
        self.init(number)
    }
    
    subscript(bounds: ClosedRange<Int>) -> [Int] {
        get {
            var bits = [Int]()
            for i in bounds.lowerBound...bounds.upperBound {
                bits.append(self >> i & 1)
            }
            return bits
        }
    }
    
    subscript(index: Int) -> Int {
        get {
            self >> index & 1
        }
    }
}

struct ControlUnit {
    enum OptionType: Int {
        case load          // I   000_00_11
        case aluImmediate  // I   001_00_11
        case store         // S   010_00_11
        case aluRegister   // R   011_00_11
        case branch        // B 1_100_0__11
        case jump          // J 1_101_1__11
    }
    
    let instruction: Int
    
    var option: OptionType {
        let opcode = instruction[0...6]
        if opcode[6] == 0 {
            return OptionType(rawValue: Int(bits: [Int](opcode[4...6])))!
        } else {
            return OptionType(rawValue: Int(bits: [Int](opcode[3...5])))!
        }
    }
    
    var registerDestination: Int {
        Int(bits: instruction[7...11])
    }
    
    var registerSource1: Int {
        Int(bits: instruction[15...19])
    }
    
    var registerSource2: Int {
        Int(bits: instruction[20...24])
    }
    
    var immediate: Int {
        func padding(_ bits: [Int], _ value: Int) -> [Int] {
            bits + [Int](repeating: value, count: 64 - bits.count)
        }
        let inst = instruction
        switch option {
        case .load, .aluImmediate:
            return Int(bits: inst[20...31])
        case .store:
            return Int(bits: inst[7...11] + inst[25...31])
        case .aluRegister:
            return 0
        case .branch:
            let b = [0] + inst[8...11] + inst[25...30] + [inst[7], inst[31]]
            return Int(bits: padding(b, inst[31]))
        case .jump:
            let j = [0] + inst[21...30] + [inst[20]] + inst[12...19] + [inst[31]]
            return Int(bits: padding(j, inst[31]))
        }
    }
}

struct CPU {
    var programCounter = 0
    var registers = [Int](repeating: 0, count: 32)
    var memory = [Int](repeating: 0, count: 1024)
    
    mutating func up() {
        let instruction = memory[programCounter >> 2]
        let controlUnit = ControlUnit(instruction: instruction)
        let rs1 = registers[controlUnit.registerSource1]
        let rs2 = registers[controlUnit.registerSource2]
        var a = rs1
        if controlUnit.option == .branch || controlUnit.option == .jump {
            a = programCounter
        }
        var b = rs2
        if controlUnit.option != .aluRegister {
            b = controlUnit.immediate
        }
        let sum = a + b
        var rd = sum
        if controlUnit.option == .load {
            rd = memory[sum >> 2]
        }
        if controlUnit.option == .store {
            memory[sum >> 2] = rs2
        }
        registers[controlUnit.registerDestination] = rd
        let branchEqual = rs1 == rs2
        programCounter += 4
        if (controlUnit.option == .branch && branchEqual) || controlUnit.option == .jump {
            programCounter = sum
        }
        
        if instruction == 0 {
            exit(0)
        }
    }
}
