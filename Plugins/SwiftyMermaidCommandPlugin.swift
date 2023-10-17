import PackagePlugin
import Foundation

@main
struct SwiftyMermaidCommandPlugin: CommandPlugin {
    // Entry point for command plugins applied to Swift Packages.
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        print("Hello, World1!")
        print("plugin dir: \(context.pluginWorkDirectory)")
        let swiftymermaid = try context.tool(named: "swiftymermaid")
        
        try outputFile(tool: swiftymermaid, arguments[1])
        print("done outputFile")
    }
    
    func outputFile(tool: PluginContext.Tool,_ folderURLString: String) throws {
        let process = Process()
        print("path: \(tool.path.string)")
        process.executableURL = URL(fileURLWithPath: tool.path.string)
        process.arguments = ["\(folderURLString)"]
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        
        try process.run()
        process.waitUntilExit()
        
        let mermaidData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        guard let mermaidString = String(data: mermaidData, encoding: .utf8) else { return }
        print("output from SwiftyMermaid")
        print(mermaidString)

        let fileURL = URL(filePath: "FromCommandPlugin.txt")
        try mermaidData.write(to: fileURL)
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SwiftyMermaidCommandPlugin: XcodeCommandPlugin {
    // Entry point for command plugins applied to Xcode projects.
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        let swiftymermaid = try context.tool(named: "swiftymermaid")
        print("Hello, World2!")
        print("plugin dir: \(context.xcodeProject.directory)")

        do {
            try outputFile(tool: swiftymermaid, context.xcodeProject.directory.string)
        } catch {
            print(error.localizedDescription)
        }
        print("done outputFile")
    }
}

#endif
