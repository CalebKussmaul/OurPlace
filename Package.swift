// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ourplace",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
            .package(url: "https://github.com/IBM-Swift/Kitura.git", from: "2.4.0"),
            .package(url: "https://github.com/IBM-Swift/Kitura-WebSocket.git", from: "2.0.0"),
            .package(url: "https://github.com/IBM-Swift/Swift-Kuery.git", from: "2.0.0"),
            .package(url: "https://github.com/IBM-Swift/Kitura-StencilTemplateEngine.git", from: "1.10.0"),
            .package(url: "https://github.com/RuntimeTools/SwiftMetrics.git", from: "2.4.0"),
            .package(url: "https://github.com/IBM-Swift/Swift-Kuery-SQLite.git", from: "1.1.0"),
            .package(url: "https://github.com/IBM-Swift/Kitura-Session.git", from: "3.2.0"),
            .package(url: "https://github.com/IBM-Swift/Kitura-Credentials.git", from: "2.3.0"),
            .package(url: "https://github.com/IBM-Swift/Kitura-CredentialsGoogle.git", from: "2.2.1"),
            //.package(url: "https://github.com/krzyzanowskim/Kitura-Session-Kuery.git", from: "1.0.0"),
            
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ourplace",
            dependencies: ["Kitura",
                           "Kitura-WebSocket",
                           "KituraStencil",
                           "SwiftMetrics",
                           "SwiftKuery",
                           "SwiftKuerySQLite",
                           "KituraSession",
                           "Credentials",
                           "CredentialsGoogle"]),
    ]
)
