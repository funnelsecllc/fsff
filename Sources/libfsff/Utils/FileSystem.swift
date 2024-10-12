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

import Foundation

///  Method to return a list of all files in a given directory
/// - Parameters
///   - folder: The directory to search for files
///   - mode: The mode to use when enumerating the directory
/// - Returns: [URL] A list of all files in the given directory
public func getDirectoryFiles(from folder: URL, mode: Mode? = nil) -> [URL] {
    // Create enumerator of regular files in `folder`
    var files: [URL] = []
    guard
        let enumerator: FileManager.DirectoryEnumerator = FileManager.default.enumerator(
            at: folder,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsPackageDescendants]
        )
    else {
        print("Failed to iterate through directory")
        return []
    }

    // Iterate through all regular files in `folder`
    for case let url as URL in enumerator {
        do {
            let attributes: URLResourceValues = try url.resourceValues(forKeys: [.isRegularFileKey])
            if attributes.isRegularFile ?? false {
                if url.pathExtension == "enc" && (mode != nil && mode! == .decrypt) {
                    files.append(url)
                    continue
                }
                print("Found file: \(url.path)")
                files.append(url)
            }
        } catch {
            print("Failed to read: \(url.path)")
        }
    }

    return files
}
