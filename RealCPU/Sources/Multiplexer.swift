func multiplexer(select: Data, input: [Data]) -> Data {
    input[select.number]
}

func decoder(select: Data) -> Data {
    var output = Data(repeating: Bit(0), count: 1024)
    output[select.number] = Bit(1)
    return output
}
