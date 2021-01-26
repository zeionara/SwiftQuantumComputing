// swift-tools-version:5.1

import PackageDescription

var dependencies: [Package.Dependency] = [
    .package(
        url: "https://github.com/apple/swift-numerics.git",
        .exact("0.0.8")
    )
]

var moduleDependencies: [PackageDescription.Target.Dependency] = []
#if os(Linux)
dependencies.append(
    .package(
        url: "https://github.com/indisoluble/CBLAS-Linux.git",
        .exact("1.0.0")
    )
)
moduleDependencies.append(
    .product(name: "CBLAS-Linux", package: "CBLAS-Linux")
)
#endif

let package = Package(
    name: "SwiftQuantumComputing",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "SwiftQuantumComputing",
            targets: [
                "SwiftQuantumComputing"
            ]
        ),
        .executable(
            name: "ShorAlgorithm",
            targets: [
                "ExampleShorAlgorithm"
            ]
        )
    ],
    dependencies: dependencies,
    targets: [
        .target(
            name: "SwiftQuantumComputing",
            dependencies: [
                .product(
                    name: "ComplexModule",
                    package: "swift-numerics"
                )
            ] + moduleDependencies,
            exclude: [
                "Drawer"
            ]
        ),
        .target(
            name: "ExampleShorAlgorithm",
            dependencies: [
                "SwiftQuantumComputing"
            ]
        ),
        .testTarget(
            name: "SwiftQuantumComputingTests",
            dependencies: [
                "SwiftQuantumComputing"
            ],
            exclude: [
                "Drawer",
                "TestDouble/Drawer"
            ]
        )
    ]
)
