import XCTest
import SwiftDemangler

class ParserTests: XCTestCase {
    func test1() throws {
        let parser = Parser(string: "$S13ExampleNumber6isEven6numberSbSi_tKF")
        let node = try parser.parse()
        
        XCTAssert(node.isEqualString(
            Node.symbol(start: .start(pos: 0, string: "$S"),
                        entity: .entity(context: .module(Identifier(pos: 0, string: "ExampleNumber")),
                                        body: .function(name: Identifier(pos: 0, string: "isEven"),
                                                        labelList: [
                                                            Identifier(pos: 0, string: "number")
                                            ],
                                                        retType: Type.single(name: "Swift.Bool"),
                                                        argType: Type.list([
                                                            Type.single(name: "Swift.Int")
                    ])
                            ))
            )
            )
        )
    }


}
