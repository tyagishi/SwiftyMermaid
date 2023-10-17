import PackagePlugin
import Foundation

@main
struct SwiftyMermaidCommandPlugin: CommandPlugin {
    // Entry point for command plugins applied to Swift Packages.
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        print("Hello, World1!")
        
        let swiftymermaid = try context.tool(named: "swiftymermaid")
        
        let projectURL = URL(fileURLWithPath: "/Volumes/SmallDesk/SmallDeskSoftware/dev/SwiftUI2023_202310/PluginSampleProject")
        try outputFile(tool: swiftymermaid, projectURL)
    }
    
    func outputFile(tool: PluginContext.Tool,_ folderURL: URL) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: tool.path.string)
        process.arguments = ["\(folderURL.absoluteString)"]
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        
        try process.run()
        process.waitUntilExit()
        
        let mermaidData = outputPipe.fileHandleForReading.readDataToEndOfFile()

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
        let projectURL = URL(fileURLWithPath: "/Volumes/SmallDesk/SmallDeskSoftware/dev/SwiftUI2023_202310/PluginSampleProject")
        do {
            try outputFile(tool: swiftymermaid, projectURL)
        } catch {
            print(error.localizedDescription)
        }
    }
}

#endif
