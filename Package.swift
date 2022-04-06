// swift-tools-version:5.5

import PackageDescription

let package = Package(
    
    name      : "waveform_plotter",
    platforms : [ .iOS("15.2") ],
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
