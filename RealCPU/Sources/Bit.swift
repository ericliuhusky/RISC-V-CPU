struct Bit: CustomStringConvertible, Equatable {
    var value: Bool
    
    init(_ value: Bool) {
        self.value = value
    }
    
    init(_ value: Int) {
        self.value = value != 0
    }
    
    var description: String {
        value ? "1" : "0"
    }
}

typealias Data = [Bit]

extension Data {
    init(_ number: Int) {
        let binaryString = String(number, radix: 2)
        var binaryArray = binaryString.map { Bit(Int(String($0))!) }
        binaryArray = binaryArray.reversed()
        for _ in 0..<(32 - binaryArray.count) {
            binaryArray.append(Bit(0))
        }
        self.init(binaryArray)
    }
    
    var number: Int {
        let binaryString = String(self.map { Character($0.description) }.reversed())
        return Int(binaryString, radix: 2)!
    }
}
