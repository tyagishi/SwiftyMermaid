import Foundation
import HatchParser
import ArgumentParser

public struct SwiftyMermaidLib {
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
        return SymbolParser.parse(source: codeString)
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
            // ignore preview/test
            guard !inherit.inheritedTypes.contains("PreviewProvider"),
                  !inherit.inheritedTypes.contains("XCTestCase") else { return "" }
            
            let inheritName = inherit.name.replacingOccurrences(of: ".", with: "_")
            for inheritedType in inherit.inheritedTypes {
                result += "\(inheritedType)<|--\(inheritName)\n"
            }
            result += """
                      class \(inheritName)["\(path+inherit.name)"] {
                        <<\(symbol.typeName())>>\n
                      """
            // add properties/methods in the future....
            result += symbol.propertyMermaid()
            
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
        } else if self is Actor {
            return "actor"
        } else if self is Struct {
            return "struct"
        } else if self is Enum {
            return "enum"
        }
        return ""
    }
}

extension Symbol {
    func propertyMermaid() -> String {
        guard let propSymbol = self as? PropertiedSymbol else { return "" }
        var propString = ""
        for prop in propSymbol.properties {
            propString.append("\(Self.accessControlSymbol(prop.accessControl))\(prop.name): \(prop.type)\n")
        }
        return propString
    }
    static func accessControlSymbol(_ string: String) -> String {
        switch string {
        case "open":         return "+"
        case "public":       return "+"
        case "internal":     return "#"
        case "fileprivate":  return "-"
        case "private":      return "-"
        default:             return ""
        }
    }
}
