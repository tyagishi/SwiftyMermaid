import PackagePlugin
import Foundation

@main
struct SwiftyMermaidCommandPlugin: CommandPlugin {
    // Entry point for command plugins applied to Swift Packages.
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        // Note: needs to be updated for handling selection from dialog
        let swiftymermaid = try context.tool(named: "swiftymermaid")
        try outputFile(tool: swiftymermaid, arguments[1])
    }
    
    func outputFile(tool: PluginContext.Tool,_ folderURLString: String) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: tool.path.string)
        process.arguments = ["\(folderURLString)"]
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        
        try process.run()
        process.waitUntilExit()
        
        let mermaidData = outputPipe.fileHandleForReading.readDataToEndOfFile()

        let fileURL = URL(filePath: "classes.text")
        try mermaidData.write(to: fileURL)
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SwiftyMermaidCommandPlugin: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        let swiftymermaid = try context.tool(named: "swiftymermaid")
        do {
            try outputFile(tool: swiftymermaid, context.xcodeProject.directory.string)
        } catch {
            print(error.localizedDescription)
        }
    }
}

#endif
