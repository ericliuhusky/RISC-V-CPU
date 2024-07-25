struct SRAMCell {
    var q = Bit(0)
    var q_ = Bit(0)
    
    mutating func set(set: Bit, reset: Bit, writeEnable: Bit) {
        let nd1 = nMosfet(source: set, gate: writeEnable)
        let nd2 = nMosfet(source: reset, gate: writeEnable)
        if let nd1 {
            q = nd1
            q_ = not(nd1)
        }
        if let nd2 {
            q = not(nd2)
            q_ = nd2
        }
    }
}

struct SRAMWord {
    var cells = [SRAMCell](repeating: SRAMCell(q: Bit(0)), count: 32)
    
    mutating func set(data: Data, writeEnable: Bit) {
        for i in 0..<32 {
            cells[i].set(set: data[i], reset: not(data[i]), writeEnable: writeEnable)
        }
    }
    
    var q: Data {
        cells.map { $0.q }
    }
}

struct RAM {
    var words: [SRAMWord] = [SRAMWord](repeating: SRAMWord(), count: 1024)
    
    mutating func up(address: Data, data: Data, writeEnable: Bit, clock: Bit) {
        let writeEnableArray = decoder(select: Data(address[2...]))
        for i in 0..<32 {
            words[i].set(data: data, writeEnable: and(and(writeEnableArray[i], writeEnable), clock))
        }
    }
    
    func data(address: Data, readEnable: Bit) -> Data {
        multiplexer(select: [readEnable], input: [Data(repeating: Bit(0), count: 32), multiplexer(select: Data(address[2...]), input: words.map { $0.q })])
    }
}
