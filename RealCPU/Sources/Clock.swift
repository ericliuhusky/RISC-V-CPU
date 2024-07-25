struct Clock {
    var clock = Bit(0)
    
    mutating func run(tikTok: (Bit) -> Void) {
        while true {
            tikTok(clock)
            clock = not(clock)
        }
    }
}
