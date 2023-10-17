// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import HatchParser
import ArgumentParser

struct SwiftyMermaid: ParsableCommand {
    static func main() {
        print("Hello world")
    }
    public static func parseProject(_ parseURL: URL) throws -> [URL: [Symbol]] {
        var results: [URL: [Symbol]] = [:]
        let enumerator = FileManager.default.enumerator(at: parseURL, includingPropertiesForKeys: [URLResourceKey.isDirectoryKey],
                                                        options: [.skipsHiddenFiles])
        while let fileURL = enumerator?.nextObject() as? URL {
            let resources = try fileURL.resourceValues(forKeys: [.isDirectoryKey])
            guard let isDir = resources.isDirectory,
                  isDir == false else { continue }
            guard fileURL.pathExtension == "swift" else { continue }
            let symbols = try Self.parseFile(fileURL)
            results[fileURL] = symbols
            
        }
        return results
    }
    public static func parseFile(_ fileURL: URL) throws -> [Symbol] {
        let codeString = try String(contentsOf: fileURL, encoding: .utf8)
        return try SymbolParser.parse(source: codeString)
    }
    
    public static func mermaid(from symbolWithURL: [URL: [Symbol]]) -> String {
        var resultString = ""
        for symbols in symbolWithURL.values {
            for symbol in symbols {
                resultString.append(Self.mermeidString(symbol, path: ""))
            }
        }
        return resultString
    }
    
    public static func mermeidString(_ symbol: Symbol, path: String) -> String {
        var result = ""

        if let inherit = symbol as? InheritingSymbol {
            for inheritedType in inherit.inheritedTypes {
                result += "\(inheritedType)<|--\(inherit.name)\n"
            }
            result += """
                      class \(inherit.name.filter{$0 != "."})["\(path+inherit.name)"] {
                        <<\(symbol.typeName())>>\n
                      """
            // add properties/methods in the future....
            result += """
                      }\n
                      """
            // care child inner declarations (not properties/method)
            if !symbol.children.isEmpty {
                let pathForChild = path + inherit.name + "."
                for child in symbol.children {
                    result.append(Self.mermeidString(child, path: pathForChild))
                }
            }
        }
        return result
    }
}

extension Symbol {
    func typeName() -> String {
        if self is ProtocolType {
            return "protocol"
        } else if self is Extension {
            return "extension"
        } else if self is Class {
            return "class"
        } else if self is Struct {
            return "struct"
        } else if self is Enum {
            return "enum"
        }
        return ""
    }
}
