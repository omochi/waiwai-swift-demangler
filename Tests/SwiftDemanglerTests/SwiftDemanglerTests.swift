import XCTest
@testable import SwiftDemangler

final class SwiftDemanglerTests: XCTestCase {
    func test1() throws {
        let sym = demangle(name: "$S13ExampleNumber6isEven6numberSbSi_tF")
        XCTAssertEqual(sym, "func ExampleNumber.isEven(number: Swift.Int) -> Swift.Bool")
    }
}
