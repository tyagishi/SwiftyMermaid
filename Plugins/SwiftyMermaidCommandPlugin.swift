import PackagePlugin
import Foundation

@main
struct SwiftyMermaidCommandPlugin: CommandPlugin {
    // Entry point for command plugins applied to Swift Packages.
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        print("execute CommandPlugin")
        // Note: needs to be updated for handling selection from dialog
        let swiftymermaid = try context.tool(named: "swiftymermaid")

        var arguments = ArgumentExtractor(arguments)

        let output = arguments.extractOption(named: "outputFile").first ?? ""
        
        let targetNames = arguments.extractOption(named: "target")
        let targets = targetNames.isEmpty ? context.package.targets : try context.package.targets(named: targetNames)
        
        let toolTargets = targets.compactMap({ $0.sourceModule }).map({ $0.directory.string})
        
        try outputFile(tool: swiftymermaid, toolTargets, outputFileURLString: output)

    }
    
    func outputFile(tool: PluginContext.Tool,_ folderURLStrings: [String],
                    outputFileURLString: String = "") throws {
        print("execute for \(folderURLStrings) to \(outputFileURLString)")
        var totalData: Data = Data()
        
        for folderURLString in folderURLStrings {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: tool.path.string)
            process.arguments = ["\(folderURLString)"]
            
            let outputPipe = Pipe()
            process.standardOutput = outputPipe
            try process.run()
            process.waitUntilExit()
            
            let mermaidData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            
            totalData.append(mermaidData)
        }

        let fileURL: URL = URL(filePath: (outputFileURLString=="") ? "classes.text" : outputFileURLString)
        try totalData.write(to: fileURL)
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SwiftyMermaidCommandPlugin: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        print("execute XcodeComandPlugin")
        let swiftymermaid = try context.tool(named: "swiftymermaid")
        var arguments = ArgumentExtractor(arguments)
        print(arguments)
        if let output = arguments.extractOption(named: "outputFile").first {
            try outputFile(tool: swiftymermaid, [context.xcodeProject.directory.string], outputFileURLString: output)
        } else {
            try outputFile(tool: swiftymermaid, [context.xcodeProject.directory.string])
        }
    }
}

#endif
