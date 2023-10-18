import PackagePlugin
import Foundation

@main
struct SwiftyMermaidCommandPlugin: CommandPlugin {
    // Entry point for command plugins applied to Swift Packages.
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        print("execute CommandPlugin")
        // Note: needs to be updated for handling selection from dialog
        let swiftymermaid = try context.tool(named: "swiftymermaid")

        let basePath = context.package.directory
        var arguments = ArgumentExtractor(arguments)

        let output = arguments.extractOption(named: "outputFile").first ?? ""
        
        for target in arguments.extractOption(named: "target") {
            let targetPath = basePath.appending(target)
            print("target: \(basePath.appending(target))")
            try outputFile(tool: swiftymermaid, targetPath.string, outputFileURLString: output)
        }
    }
    
    func outputFile(tool: PluginContext.Tool,_ folderURLString: String, outputFileURLString: String = "") throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: tool.path.string)
        process.arguments = ["\(folderURLString)"]
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        
        try process.run()
        process.waitUntilExit()
        
        let mermaidData = outputPipe.fileHandleForReading.readDataToEndOfFile()

        let fileURL: URL = URL(filePath: (outputFileURLString=="") ? "classes.text" : outputFileURLString)
        try mermaidData.write(to: fileURL)
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
            try outputFile(tool: swiftymermaid, context.xcodeProject.directory.string, outputFileURLString: output)
        } else {
            try outputFile(tool: swiftymermaid, context.xcodeProject.directory.string)
        }
    }
}

#endif
