import XCTest
import SwiftDemangler

class ParserTests: XCTestCase {
    func testExample() throws {
        let parser = Parser(string: "$S13ExampleNumber6isEven6numberSbSi_tKF")
        let node = try parser.parse()
        
        XCTAssertEqual(node.description, "$S13ExampleNumber")
    }


}
