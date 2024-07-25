struct RSLatch {
    var q = Bit(0)
    var q_ = Bit(0)
    
    mutating func set(set: Bit, reset: Bit) {
        if set == Bit(1) {
            q_ = nor(set, q)
            q = nor(reset, q_)
        } else if reset == Bit(1) {
            q = nor(reset, q_)
            q_ = nor(set, q)
        }
    }
}

struct DLatch {
    var rsLatch = RSLatch()
    
    mutating func set(data: Bit, enable: Bit) {
        rsLatch.set(set: and(data, enable), reset: and(not(data), enable))
    }
    
    var q: Bit {
        rsLatch.q
    }
}

struct DFlipFlop {
    var dLatch1 = DLatch()
    var dLatch2 = DLatch()
    
    mutating func up(data: Bit, clock: Bit) {
        dLatch1.set(data: data, enable: not(clock))
        dLatch2.set(data: dLatch1.q, enable: clock)
    }
    
    var q: Bit {
        dLatch2.q
    }
}

struct Register {
    var dFlipFlops = [DFlipFlop](repeating: DFlipFlop(), count: 32)
    
    mutating func up(data: Data, writeEnable: Bit, clock: Bit) {
        for i in 0..<32 {
            dFlipFlops[i].up(data: data[i], clock: and(clock, writeEnable))
        }
    }
    
    var q: Data {
        dFlipFlops.map { $0.q }
    }
}
