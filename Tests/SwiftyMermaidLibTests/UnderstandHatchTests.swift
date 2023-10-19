//
//  UnderstandHatchTests.swift
//
//  Created by : Tomoaki Yagishita on 2023/10/13
//  © 2023  SmallDeskSoftware
//

import XCTest
import HatchParser
@testable import SwiftyMermaidLib

final class UnderstandHatchTests: XCTestCase {
    
    func test_Parse_empty() throws {
        let testString = ""
        let symbols = try SymbolParser.parse(source: testString)
        XCTAssertEqual(symbols.count, 0)
    }
    
    func test_Parse_Basic1() throws {
//        let testBundle = Bundle(for: type(of: self))
//        print("testBundle path: \(testBundle.bundlePath)")
//        let testFileURL = try XCTUnwrap(testBundle.url(forResource: "File1", withExtension: "scode"))
//        print(testFileURL)
//        let testString = try String(contentsOf: testFileURL, encoding: .utf8)
//        
//        let symbols = try SymbolParser.parse(source: testString)
//        XCTAssertEqual(symbols.count, 3)
        XCTAssertTrue(true)
    }
    
//    func test_FileManager_contentsOfDirectory() throws {
//        let tmpURL = FileManager.default.temporaryDirectory
//        let enumerator = FileManager.default.enumerator(at: tmpURL, includingPropertiesForKeys: [.isDirectoryKey],
//                                                        options: [.skipsHiddenFiles])!
//        
//        for case let fileURL as URL in enumerator {
//            let resources = try fileURL.resourceValues(forKeys: [.isDirectoryKey])
//            guard let isDir = resources.isDirectory,
//                  isDir == false else { continue }
//            //print("file: \(fileURL.path()) isDir: \(resources.isDirectory ?? false)")
//        }
//        XCTAssertTrue(true)
//        
////        var ite = FileManager.default.enumerator(at: tmpURL, includingPropertiesForKeys: nil)//, includingPropertiesForKeys: [.skipHiddenFiles])
////        while let item = ite?.nextObject() as? String {
////            print("Found: \(item)")
////        }
////        for dir in try FileManager.default.contentsOfDirectory(at: tmpURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) {
////            print("Found: \(dir.absoluteString)")
////        }
//    }

}
