// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import HatchParser
import ArgumentParser
import SwiftyMermaidLib

@main
struct SwiftyMermaid: ParsableCommand {
    @Argument(help: "input folder")
    var folderURLString: String

    @Option(help: "flag to include test(default: exclude test) note: not implemented yet")
    var includeTest: Bool = false
    
    @Option(help: "output file(default: standard output)")
    var outputFile: String? = nil
    
    mutating func run() throws {
        let specifiedPath = (folderURLString as NSString).expandingTildeInPath
        guard FileManager.default.fileExists(atPath: specifiedPath) else { return }
        guard let folderURL = URL(string: specifiedPath) else { return }

        let extractedSymbols = try SwiftyMermaidLib.parseProject(folderURL)
        let extractedMermaid = SwiftyMermaidLib.mermaid(from: extractedSymbols)

        if let outputFile = outputFile,
           let outputURL = URL(string: outputFile) {
            try extractedMermaid.data(using: .utf8)?.write(to: outputURL)
        } else {
            try FileHandle.standardOutput.write(contentsOf: extractedMermaid.data(using: .utf8)!)

        }
    }
}
