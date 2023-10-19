import XCTest
@testable import SwiftyMermaidLib

final class SwiftyMermaidTests: XCTestCase {
    func testExample() throws {
        let projectDir = FileManager.default.currentDirectoryPath
        print(projectDir)
    }

    func test_testResourceAccess() async throws {
        let testBundle = Bundle(for: type(of: self))
        print("testBundle is \(testBundle.bundlePath)")
        //let testFileURL = try XCTUnwrap(testBundle.url(forResource: "File1", withExtension: "text"))
//        let results = try SwiftyMermaidLib.parseFile(testFileURL)
//        XCTAssertEqual(results.count, 3)
//        dump(results)
    }
}
