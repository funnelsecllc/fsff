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

    @Argument(help: "The main file or directory target.")
    var oneTarget: String

    @Option(name: .shortAndLong, help: "The second target file. Use with `compare` mode.")
    var twoTarget: String? = nil

    @Option(name: .shortAndLong, help: "The size of the key to use.")
    var size: Size? = nil

    @Option(name: .shortAndLong, help: "The key file for encryption and decryption.")
    var keyFile: String? = nil

    @Option(name: .shortAndLong, help: "The encryption type to use.")
    var encryptionType: EncryptionType? = nil

    @Flag(name: .shortAndLong, help: "Enable directory parsing for encryption or decryption.")
    var directory: Bool = false

    mutating func run() throws {
        if mode == .generate && directory {
            print("The `generate` mode does not support directory parsing.")
            throw ArgumentParser.ExitCode.failure
        }

        let fileManager: FileManager = FileManager.default
        let target1Url: URL = URL(fileURLWithPath: oneTarget, isDirectory: directory)

        if mode == .generate {
            // Ensure that the key size has been configured
            if size == nil {
                print("Missing size option.")
                throw ArgumentParser.ExitCode.failure
            }

            // Attempt to create and dave the key file
            let isKeyGenerationSuccessful: Bool = generateKey(with: size!, to: target1Url)
            if !isKeyGenerationSuccessful {
                print("Failed to save key file.")
                throw ArgumentParser.ExitCode.failure
            }

            print("Saved key file to: '\(target1Url.path)'.")
            return
        }

        // Ensure that the target file exists
        if !fileManager.fileExists(atPath: target1Url.path, isDirectory: &directory) {
            print("Does not exist: '\(target1Url.path)'.")
            throw ArgumentParser.ExitCode.failure
        }
        // Verifiy what mode is selected
        if mode == .compare {
            // Ensure that the second target file exists
            if twoTarget == nil || twoTarget!.isEmpty {
                print("Missing target2.")
                throw ArgumentParser.ExitCode.failure
            }
            if !fileManager.fileExists(atPath: twoTarget!) {
                print("Does not exist: '\(twoTarget!)'.")
                throw ArgumentParser.ExitCode.failure
            }
        }
        // Ensure that these modes have the encryptionType set
        if (mode == .encrypt || mode == .decrypt) && encryptionType == nil {
            print("Encryption type must be set.")
            throw ArgumentParser.ExitCode.failure
        }

        switch mode {
        // Run the hash command
        case .hash:
            let results: [String] = getFileHashes(from: target1Url)
            print(results.joined(separator: "\n"))
            break

        // Run the compare command
        case .compare:
            let isSameHash: Bool = compareHashes(
                target1: target1Url,
                target2: URL(fileURLWithPath: twoTarget!)
            )
            if !isSameHash {
                print("Hashes do not match.")
                throw ArgumentParser.ExitCode.failure
            }

            print("Hashes match.")
            break

        // Run the encrypt command
        case .encrypt:
            if keyFile == nil || keyFile!.isEmpty {
                print("Missing key file option.")
                throw ArgumentParser.ExitCode.failure
            }

            let keyFileUrl: URL = URL(fileURLWithPath: keyFile!)
            if !fileManager.fileExists(atPath: keyFileUrl.path) {
                print("Key file does not exist: '\(keyFileUrl.path)'.")
                throw ArgumentParser.ExitCode.failure
            }

            let isEncryptionSuccessful: Bool = encrypt(
                target: target1Url, 
                keyFile: keyFileUrl,
                encryptionType: encryptionType!,
                isDirectory: directory,
                mode: mode
            )
            if !isEncryptionSuccessful {
                print("Failed to encrypt file: '\(target1Url.path)'.")
                throw ArgumentParser.ExitCode.failure
            }

            print("Encryption successful.")
            break

        // Run the decrypt command
        case .decrypt:
            if keyFile == nil || keyFile!.isEmpty {
                print("Missing key file option.")
                throw ArgumentParser.ExitCode.failure
            }

            let keyFileUrl: URL = URL(fileURLWithPath: keyFile!)
            if !fileManager.fileExists(atPath: keyFileUrl.path) {
                print("Key file does not exist: '\(keyFileUrl.path)'.")
                throw ArgumentParser.ExitCode.failure
            }

            let isDecryptionSuccessful: Bool = decrypt(
                target: target1Url, 
                keyFile: keyFileUrl, 
                encryptionType: encryptionType!,
                isDirectory: directory,
                mode: mode
            )
            if !isDecryptionSuccessful {
                print("Failed to decrypt file: '\(target1Url.path)'.")
                throw ArgumentParser.ExitCode.failure
            }
            print("Decryption successful.")
            break

        default:
            print("Invalid option.")
            throw ArgumentParser.ExitCode.failure
        }
    }
}
