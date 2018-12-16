import Foundation

public class NodePrinter {
    private let symbol: Symbol
    
    public init(symbol: Symbol) {
        self.symbol = symbol
    }
    
    public func print() -> String {
        return print(symbol.entity)
    }
    
    private var context: Identifier?
    
    private func print(_ node: Node) -> String {
        switch node {
        case .entity(context: let c, body: let b):
            if case .module(let id) = c {
                self.context = id
            } else {
                self.context = nil
            }
            return print(b)
        case .function(name: let n, labelList: let ll,
                       retType: let r, argType: let a):
            return printFunction(context: self.context!,
                                 name: n, labelList: ll, retType: r, argType: a)
        case .garbage(pos: _, string: _):
            return ""
        case .module(_):
            fatalError()
        }
    }
    
    private func printFunction(context: Identifier,
                               name: Identifier,
                               labelList: [Identifier],
                               retType: Type,
                               argType: Type) -> String
    {
        func printArg() -> String {
            if case .list(let ts) = argType {
                return print(labelList: labelList,
                             types: ts)
            }
            fatalError()
        }
            
        return "func \(print(context)).\(print(name))\(printArg()) -> \(print(retType))"
    }

    private func print(labelList: [Identifier],
                       types: [Type]) -> String
    {
        return "(" +
        zip(labelList, types).map { (z) in
            print(label: z.0, type: z.1)
            }.joined(separator: ", ") + ")"
    }

    
    private func print(label: Identifier, type: Type) -> String {
        return label.string + ": " + print(type)
    }
    
    private func print(_ type: Type) -> String {
        switch type {
        case .single(name: let n): return n
        case .list(let ts): return "(" + ts.map { print($0) }.joined(separator: ", ") + ")"
        }
    }
    
    private func print(_ id: Identifier) -> String {
        return id.string
    }
}
