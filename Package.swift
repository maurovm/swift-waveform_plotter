// swift-tools-version:5.9

import PackageDescription

let package = Package(
    
    name      : "swift-waveform_plotter",
    platforms : [ .iOS("17.2") ],
    products  :
        [
            .library(
                name    : "WaveformPlotter",
                targets : ["WaveformPlotter"]
            )
        ],
    dependencies: [],
    targets:
        [
            .target(
                name         : "WaveformPlotter",
                dependencies : [],
                path         : "Sources"
            )
        ]

)
