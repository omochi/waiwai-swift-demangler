import Foundation

public indirect enum Node {
    case symbol(start: Node, entity: Node)
    case entity(context: Node, body: Node)
    case module(Identifier)
    case function(name: Identifier, labelList: [Identifier])
    case identifier(Identifier)
    case start(pos: Int, string: String)
    case garbage(pos: Int, string: String)
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

//extension Node : CustomStringConvertible {
//    public var description: String {
//        let pr = NodePrinter(node: self)
//        return pr.print()
//    }
//}



extension Node {
    public func isEqualString(_ b: Node) -> Bool {
        switch self {
        case .symbol(start: let aS, entity: let aE):
            if case .symbol(start: let bS, entity: let bE) = b {
                return aS.isEqualString(bS) && aE.isEqualString(bE)
            }
        case .entity(context: let aC, body: let aB):
            if case .entity(context: let bC, body: let bB) = b {
                return aC.isEqualString(bC) && aB.isEqualString(bB)
            }
        case .module(let aI):
            if case .module(let bI) = b {
                return aI.isEqualString(bI)
            }
        case .function(name: let aN, labelList: let aLL):
            if case .function(name: let bN, labelList: let bLL) = b {
                return aN.isEqualString(bN) &&
                    aLL.elementsEqual(bLL) { $0.isEqualString($1) }
            }
        case .identifier(let aI):
            if case .identifier(let bI) = b {
                return aI.string == bI.string
            }
        case .start(pos: _, string: let aS):
            if case .start(pos: _, string: let bS) = b {
                return aS == bS
            }
        case .garbage:
            if case .garbage = b {
                return true
            }
        }
        return false
    }
}
