import Foundation

public class Parser {
    public enum Error : Swift.Error {
        case invalidEndOfString
        case invalidCharacter(Character)
    }
    
    private let chars: [Character]
    
    private var pos: Int
    
    public init(string: String) {
        self.chars = string.map { $0 }
        self.pos = 0
    }
    
    public func parse() throws -> Node {
        return try parseGlobal()
    }
    
    private func parseGlobal() throws -> Node {
        let start = try parseStart()
        return Node.symbol(start: start)
    }
    
    private func parseStart() throws -> Node {
        let pos = self.pos
        
        guard let c0 = readChar() else { throw Error.invalidEndOfString }
        guard c0 == Character("$") else {
            throw Error.invalidCharacter(c0)
        }
        
        guard let c1 = readChar() else { throw Error.invalidEndOfString }
        guard c1 == Character("S") else {
            throw Error.invalidCharacter(c1)
        }
        
        return Node.start(pos: pos, string: String([c0, c1]))
    }
    
    private func readChar() -> Character? {
        guard pos < chars.count else {
            return nil
        }
        let char = chars[pos]
        pos += 1
        return char
    }
}
