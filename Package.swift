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
//        .library(name: "SwiftyMermaid", targets: ["SwiftyMermaid"]),
        .executable(name: "swiftymermaid", targets: ["swiftymermaid"]),
        .plugin( name: "SwiftyMermaidCommandPlugin",
                 targets: [ "SwiftyMermaidCommandPlugin" ]
                 )
    ],
    dependencies: [
        .package(url: "https://github.com/sdidla/Hatch", from: "508.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.3")
    ],
    targets: [
//        .target(name: "SwiftyMermaid",
//                dependencies: [ .product(name: "HatchParser", package: "Hatch") ]
//               ),
        .plugin(
            name: "SwiftyMermaidCommandPlugin",
            capability: .command(intent: .custom( verb: "SwiftyMermaidCommandPlugin",
                                                  description: "prints hello world"),
                                 permissions: [.writeToPackageDirectory(reason: "output mermaid file")]),
            dependencies: [ "swiftymermaid" ]
        ),
        .executableTarget(name: "swiftymermaid",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "HatchParser", package: "Hatch")]
        ),
        .testTarget(
            name: "SwiftyMermaidTests",
            dependencies: ["swiftymermaid"]),

    ]
)
