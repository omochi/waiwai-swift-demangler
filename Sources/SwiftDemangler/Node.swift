import Foundation

public indirect enum Node {
    case symbol(start: Node)
    case start(pos: Int, string: String)
}


extension Node : CustomStringConvertible {
    public var description: String {
        switch self {
        case .symbol(start: let x): return x.description
        case .start(pos: _, string: let s): return s
        }
    }
}
