// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import HatchParser
import ArgumentParser

@main
struct SwiftyMermaid: ParsableCommand {
    @Argument(help: "input folder")
    var folderURLString: String

    @Option(help: "flag to include test(default: exclude test)")
    var includeTest: Bool = false
    
    @Option(help: "output file(default: classes.text)")
    var outputFile: String? = nil
    
    mutating func run() throws {
        let specifiedPath = (folderURLString as NSString).expandingTildeInPath
        guard FileManager.default.fileExists(atPath: specifiedPath) else { return }
        guard let folderURL = URL(string: specifiedPath) else { return }

        let extractedSymbols = try Self.parseProject(folderURL)
        let extractedMermaid = Self.mermaid(from: extractedSymbols)

        if let outputFile = outputFile,
           let outputURL = URL(string: outputFile) {
            print("output to file")
            try extractedMermaid.data(using: .utf8)?.write(to: outputURL)
        } else {
            try FileHandle.standardOutput.write(contentsOf: extractedMermaid.data(using: .utf8)!)

        }
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
        for url in symbolWithURL.keys {
            resultString.append("%% \(url.lastPathComponent)\n")
            guard let symbols = symbolWithURL[url] else { continue }
            for symbol in symbols {
                resultString.append(Self.mermaidString(symbol, path: ""))
            }
        }
        return resultString
    }
    
    public static func mermaidString(_ symbol: Symbol, path: String) -> String {
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
                    result.append(Self.mermaidString(child, path: pathForChild))
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
