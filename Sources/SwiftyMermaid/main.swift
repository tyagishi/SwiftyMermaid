// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import HatchParser
import ArgumentParser

struct SwiftyMermaid: ParsableCommand {
    static func main() {
        print("Hello world")
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
