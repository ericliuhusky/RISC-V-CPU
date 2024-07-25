
func halfAdder(a: Bit, b: Bit) -> (sum: Bit, carry: Bit) {
    (xor(a, b), and(a, b))
}

func fullAdder(a: Bit, b: Bit, carry: Bit) -> (sum: Bit, carry: Bit) {
    let (sum1, carry1) = halfAdder(a: a, b: b)
    let (sum2, carry2) = halfAdder(a: sum1, b: carry)
    return (sum2, or(carry1, carry2))
}

func adder(a: Data, b: Data, carry: Bit) -> (sum: Data, carry: Bit) {
    var sum = Data(repeating: Bit(0), count: 32)
    var carry = carry
    for i in 0..<32 {
        let (sum1, carry1) = fullAdder(a: a[i], b: b[i], carry: carry)
        sum[i] = sum1
        carry = carry1
    }
    return (sum, carry)
}
