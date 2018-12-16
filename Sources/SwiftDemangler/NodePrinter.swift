import Foundation

//public class NodePrinter {
//    private let node: Node
//    
//    public init(node: Node) {
//        self.node = node
//    }
//    
//    public func print() -> String {
//        switch node {
//        case .symbol(start: let s, entity: let e):
//            return s.description + e.description
//        case .entity(context: let c, body: let b):
//            return c.description + b.description
//        case .identifier(pos: _, string: let s):
//            return s
//        case .start(pos: _, string: let s):
//            return s
//        case .garbage(pos: _, string: _):
//            return ""
//        }
//    }
//}
