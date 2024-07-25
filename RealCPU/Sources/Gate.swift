
func not(_ a: Bit) -> Bit {
    let pDrain = pMosfet(source: Bit(1), gate: a)
    let nDrain = nMosfet(source: Bit(0), gate: a)
    if let pDrain {
        return pDrain
    }
    if let nDrain {
        return nDrain
    }
    fatalError()
}

func nand(_ a: Bit, _ b: Bit) -> Bit {
    let pd1 = pMosfet(source: Bit(1), gate: a)
    let pd2 = pMosfet(source: Bit(1), gate: b)
    let nd1 = nMosfet(source: Bit(0), gate: a)
    let nd2 = nMosfet(source: nd1, gate: b)
    if let pd1 {
        return pd1
    }
    if let pd2 {
        return pd2
    }
    if let nd2 {
        return nd2
    }
    fatalError()
}

func and(_ a: Bit, _ b: Bit) -> Bit {
    not(nand(a, b))
}

func nor(_ a: Bit, _ b: Bit) -> Bit {
    let pd1 = pMosfet(source: Bit(1), gate: a)
    let pd2 = pMosfet(source: pd1, gate: b)
    let nd1 = nMosfet(source: Bit(0), gate: a)
    let nd2 = nMosfet(source: Bit(0), gate: b)
    if let pd2 {
        return pd2
    }
    if let nd1 {
        return nd1
    }
    if let nd2 {
        return nd2
    }
    fatalError()
}

func or(_ a: Bit, _ b: Bit) -> Bit {
    not(nor(a, b))
}

func xor(_ a: Bit, _ b: Bit) -> Bit {
    or(and(not(a), b), and(a, not(b)))
}
