import Foundation

public indirect enum Node {
    case symbol(start: Node, entity: Node)
    case entity(context: Node, body: Node)
    case identifier(pos: Int, string: String)
    case start(pos: Int, string: String)
    case garbage(pos: Int, string: String)
}

extension Node : CustomStringConvertible {
    public var description: String {
        let pr = NodePrinter(node: self)
        return pr.print()
    }
}
