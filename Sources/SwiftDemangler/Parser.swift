import Foundation

public class Parser {
    public enum Error : Swift.Error {
        case invalidEndOfString
        case invalidStartCharacter(Character)
        case invalidNumber(Character)
        case invalidIDCharacter(Character)
        case invalidCharacter(Character)
        case invalidType
    }
    
    private let chars: [Character]
    
    private var pos: Int
    
    private let char0: Character
    private let char1: Character
    private let char9: Character
    private let charSA: Character
    private let charSZ: Character
    private let charSY: Character
    private let charLA: Character
    private let charLZ: Character
    private let charLS: Character
    private let charUScore: Character
    private let charDollar: Character
    
    public init(string: String) {
        self.chars = string.map { $0 }
        self.pos = 0
        
        self.char0 = Character("0")
        self.char1 = Character("1")
        self.char9 = Character("9")
        self.charSA = Character("a")
        self.charSZ = Character("z")
        self.charSY = Character("y")
        self.charLA = Character("A")
        self.charLZ = Character("Z")
        self.charLS = Character("S")
        self.charUScore = Character("_")
        self.charDollar = Character("$")
    }
    
    public func parse() throws -> Node {
        return try parseGlobal()
    }
    
    private func parseGlobal() throws -> Node {
        let start = try parseStart()
        let entity = try parseEntity()
        return Node.symbol(start: start, entity: entity)
    }
    
    private func parseEntity() throws -> Node {
        let context = try parseContext()
        let entity = try parseEntitySpec()
        return Node.entity(context: context,
                           body: entity)
    }
    
    private func parseContext() throws -> Node {
        return try parseModule()
    }
    
    private func parseModule() throws -> Node {
        let id = try parseIdentifier()
        return Node.module(id)
    }
    
    private func parseEntitySpec() throws -> Node {
        let name = try parseIdentifier()
        let labelList = try parseLabelList()
        let (ret, arg) = try parseFunctionSignature()
        return Node.function(name: name, labelList: labelList,
                             retType: ret, argType: arg)
    }
    
    private func parseFunctionSignature() throws -> (Type, Type) {
        let ret = try parseParamsType()
        let arg = try parseParamsType()
        return (ret, arg)
    }
    
    private func parseParamsType() throws -> Type {
        return try parseType()
    }
    
    private func parseType() throws -> Type {
        if let _ = (mayParse { try parseEmptyList() }) {
            return Type.list([])
        }
        
        let t0 = try parseAnyGenericType()
        
        let pos = self.pos
        
        guard let c = readChar() else {
            return t0
        }
        if c != charUScore {
            self.pos = pos
            return t0
        }
        
        var ts: [Type] = [t0]
        
        while true {
            guard let t1 = (mayParse { try parseType() }) else {
                break
            }
            ts.append(t1)
        }
        
        return Type.list(ts)
    }
    
    private func parseAnyGenericType() throws -> Type {
        guard let c = readChar() else {
            throw Error.invalidEndOfString
        }
        
        if c == charLS {
            guard let d = readChar() else {
                throw Error.invalidEndOfString
            }
            switch d {
            case Character("i"): return Type.single(name: "Swift.Int")
            case Character("b"): return Type.single(name: "Swift.Bool")
            case Character("S"): return Type.single(name: "Swift.String")
            case Character("f"): return Type.single(name: "Swift.Float")
            default: break
            }
            throw Error.invalidCharacter(d)
        }
        
        throw Error.invalidCharacter(c)
    }
    
    private func parseLabelList() throws -> [Identifier] {
        if let _ = (mayParse { try parseEmptyList() }) {
            return []
        }
 
        var list: [Identifier] = []
        while true {
            let pos = self.pos
            if let _ = (mayReadChar { $0 == charUScore }) {
                let id = Identifier(pos: pos, string: "")
                list.append(id)
                continue
            }
            
            guard let id = (mayParse { try parseIdentifier() }) else {
                break
            }
            list.append(id)
        }
        
        return list
    }
    
    private func parseEmptyList() throws -> Void {
        guard let c = readChar() else {
            throw Error.invalidEndOfString
        }
        guard c == charSY else {
            throw Error.invalidCharacter(c)
        }
        return
    }

    private func parseIdentifier() throws -> Identifier {
        let pos = self.pos
        let len = try parseNatural()
        let id = try parseIdentifierString(length: len)
        return Identifier(pos: pos, string: id)
    }
    
    private func parseIdentifierString(length: Int) throws -> String {
        var value: [Character] = []
        
        for i in 0..<length {
            guard let c = readChar() else {
                throw Error.invalidEndOfString
            }
            if i == 0 {
                guard isIDStart(c) else {
                    throw Error.invalidIDCharacter(c)
                }
            } else {
                guard isIDBody(c) else {
                    throw Error.invalidIDCharacter(c)
                }
            }
            value.append(c)
        }
        
        return String(value)
    }
    
    private func parseNatural() throws -> Int {
        func toI(_ char: Character) -> Int {
            return Int(char.unicodeScalars.first!.value -
                char0.unicodeScalars.first!.value)
        }
        
        var value: Int = 0
        
        guard let c = readChar() else {
            throw Error.invalidEndOfString
        }
        guard isNaturalStart(c) else {
            throw Error.invalidNumber(c)
        }
        value += toI(c)
        
        while true {
            guard let c = (mayReadChar { isNaturalBody($0) }) else {
                break
            }
            value = value * 10 + toI(c)
        }
        
        return value
    }
    
    private func mayParse<T>(_ f: () throws -> T) -> T? {
        let pos = self.pos
        do {
            return try f()
        } catch {
            self.pos = pos
            return nil
        }
    }
    
    private func isIDStart(_ char: Character) -> Bool {
        return char == charUScore ||
            isSmallAlpha(char) ||
            isLargeAlpha(char)
    }
    
    private func isIDBody(_ char: Character) -> Bool {
        return char == charUScore ||
            char == charDollar ||
            isSmallAlpha(char) ||
            isLargeAlpha(char) ||
            isNaturalBody(char)
    }
    
    private func isSmallAlpha(_ char: Character) -> Bool {
        return charSA <= char && char <= charSZ
    }
    
    private func isLargeAlpha(_ char: Character) -> Bool {
        return charLA <= char && char <= charLZ
    }
    
    private func isNaturalStart(_ char: Character) -> Bool {
        return char1 <= char && char <= char9
    }
    
    private func isNaturalBody(_ char: Character) -> Bool {
        return char0 <= char && char <= char9
    }
    
    private func readAsGarbageToEnd() throws -> Node {
        let pos = self.pos
        var chars: [Character] = []
        while true {
            guard let c = readChar() else {
                break
            }
            chars.append(c)
        }
        return Node.garbage(pos: pos, string: String(chars))
    }
    
    private func parseStart() throws -> Node {
        let pos = self.pos
        
        guard let c0 = readChar() else { throw Error.invalidEndOfString }
        guard c0 == charDollar else {
            throw Error.invalidStartCharacter(c0)
        }
        
        guard let c1 = readChar() else { throw Error.invalidEndOfString }
        guard c1 == Character("S") else {
            throw Error.invalidStartCharacter(c1)
        }
        
        return Node.start(pos: pos, string: String([c0, c1]))
    }
    
    private func mayReadChar(_ pred: (Character) -> Bool) -> Character? {
        let pos = self.pos
        guard let char = readChar() else {
            return nil
        }
        guard pred(char) else {
            self.pos = pos
            return nil
        }
        return char
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
