// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyMermaid",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "SwiftyMermaidLib", targets: ["SwiftyMermaidLib"]),
        .executable(name: "swiftymermaid", targets: ["swiftymermaid"]),
        .plugin( name: "SwiftyMermaidCommandPlugin",
                 targets: [ "SwiftyMermaidCommandPlugin" ]
                 )
    ],
    dependencies: [
        .package(url: "https://github.com/tyagishi/Hatch", branch: "main"),
        .package(url: "https://github.com/apple/swift-syntax", from: "509.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.3")
    ],
    targets: [
        .target(name: "SwiftyMermaidLib",
                dependencies: [
                    .product(name: "ArgumentParser", package: "swift-argument-parser"),
                    .product(name: "SwiftParser", package: "swift-syntax"),
                    .product(name: "HatchParser", package: "Hatch")]
               ),
        .executableTarget(name: "swiftymermaid",
            dependencies: [ "SwiftyMermaidLib" ]
        ),
        .plugin(
            name: "SwiftyMermaidCommandPlugin",
            capability: .command(intent: .custom( verb: "SwiftyMermaidCommandPlugin",
                                                  description: "extract structure from swift into mermaid format"),
                                 permissions: [.writeToPackageDirectory(reason: "output mermaid file")]),
            dependencies: [ "swiftymermaid" ]
        ),
        .testTarget(
            name: "SwiftyMermaidLibTests",
            dependencies: ["SwiftyMermaidLib",
                           .product(name: "HatchParser", package: "Hatch")
            ],
            resources: [
                .copy("Resources")
            ])
    ]
)
