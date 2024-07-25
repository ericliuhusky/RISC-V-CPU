
func pMosfet(source: Bit?, gate: Bit) -> Bit? {
    guard let source else { return nil }
    if gate == Bit(0) && source == Bit(1) {
        return Bit(1)
    }
    return nil
}

func nMosfet(source: Bit?, gate: Bit) -> Bit? {
    guard let source else { return nil }
    if gate == Bit(1) && source == Bit(0) {
        return Bit(0)
    }
    return nil
}
