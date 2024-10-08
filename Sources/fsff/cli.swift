// MIT License

// Copyright (c) 2024 FunnelSec LLC

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import ArgumentParser
import Foundation
import libfsff

@main
struct fsff: ParsableCommand {
    @Argument(help: "The mode to run in.")
    var mode: Mode

    @Option(name: .shortAndLong, help: "The first target file")
    var oneTarget: String = ""

    @Option(name: .shortAndLong, help: "The second target file. Use with compare mode")
    var twoTarget: String? = nil

    mutating func run() throws {
        let fileManager: FileManager = FileManager.default
        let target1Path: URL = URL(fileURLWithPath: oneTarget)

        // Ensure that the target file exists
        if !fileManager.fileExists(atPath: target1Path.path) {
            print("Does not exist: \(target1Path.path)")
            throw ArgumentParser.ExitCode.failure
        }
        // Verifiy what mode is selected
        if mode == .compare {
            // Ensure that the second target file exists
            if twoTarget == nil {
                print("Missing target2")
                throw ArgumentParser.ExitCode.failure
            }
            if !fileManager.fileExists(atPath: twoTarget!) {
                print("Does not exist: \(twoTarget!)")
                throw ArgumentParser.ExitCode.failure
            }
        }

        switch mode {
        // Run the hash command
        case .hash:
            let results: [String] = getFileHashes(from: target1Path)
            print(results.joined(separator: "\n"))
            break

        // Run the compare command
        case .compare:
            let isSameHash: Bool = compareHashes(
                target1: target1Path,
                target2: URL(fileURLWithPath: twoTarget!)
            )

            if !isSameHash {
                print("Hashes do not match.")
                throw ArgumentParser.ExitCode.failure
            } else {
                print("Hashes match.")
            }
            break

        default:
            print("Invalid option")
            throw ArgumentParser.ExitCode.failure
        }
    }
}
