import Foundation

public indirect enum Node {
    case entity(context: Node, body: Node)
    case module(Identifier)
    case function(name: Identifier, labelList: [Identifier],
        retType: Type, argType: Type)
    case garbage(pos: Int, string: String)
}

public struct Symbol : CustomStringConvertible {
    public var start: String
    public var entity: Node
    
    public init(start: String,
                entity: Node)
    {
        self.start = start
        self.entity = entity
    }
    
    public var description: String {
        return NodePrinter(symbol: self).print()
    }
}

public struct Identifier {
    public var pos: Int
    public var string: String
    
    public init(pos: Int,
                string: String)
    {
        self.pos = pos
        self.string = string
    }
    
    public func isEqualString(_ b: Identifier) -> Bool {
        return string == b.string
    }
}

public indirect enum Type {
    case single(name: String)
    case list([Type])
    
    public func isEqualString(_ b: Type) -> Bool {
        switch self {
        case .single(name: let aN):
            if case .single(name: let bN) = b {
                return aN == bN
            }
        case .list(let aA):
            if case .list(let bA) = b {
                return aA.elementsEqual(bA) { $0.isEqualString($1) }
            }
        }
        return false
    }
}

extension Node {
    public func isEqualString(_ b: Node) -> Bool {
        switch self {
        case .entity(context: let aC, body: let aB):
            if case .entity(context: let bC, body: let bB) = b {
                return aC.isEqualString(bC) && aB.isEqualString(bB)
            }
        case .module(let aI):
            if case .module(let bI) = b {
                return aI.isEqualString(bI)
            }
        case .function(name: let aN, labelList: let aLL,
                       retType: let aR, argType: let aA):
            if case .function(name: let bN, labelList: let bLL,
                              retType: let bR, argType: let bA) = b
            {
                return aN.isEqualString(bN) &&
                    aLL.elementsEqual(bLL) { $0.isEqualString($1) } &&
                    aR.isEqualString(bR) &&
                    aA.isEqualString(bA)
            }
        case .garbage:
            if case .garbage = b {
                return true
            }
        }
        return false
    }
}
