import XCTest
@testable import swiftymermaid

final class SwiftyMermaidTests: XCTestCase {
    func testExample() throws {
        let projectDir = FileManager.default.currentDirectoryPath
        print(projectDir)
    }

    func test_testResourceAccess() async throws {
        let testBundle = Bundle(for: type(of: self))
        let testFileURL = try XCTUnwrap(testBundle.url(forResource: "File1", withExtension: "scode"))
        let results = try SwiftyMermaid.parseFile(testFileURL)
        XCTAssertEqual(results.count, 3)
        dump(results)
    }
}
