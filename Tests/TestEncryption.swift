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

import XCTest

@testable import libfsff

class TestEncryption: XCTestCase {
    let keyFileUrl: URL = URL(fileURLWithPath: "Tests/Support/test.key")

    func test_encryptFile() throws {
        let target: URL = URL(fileURLWithPath: "Tests/Support/Encrypt/tmp.txt")
        let result: Bool = encrypt(
            target: target,
            keyFile: keyFileUrl,
            encryptionType: .aes,
            isDirectory: false,
            mode: .encrypt
        )
        let encryptedFileUrl: URL = URL(fileURLWithPath: "Tests/Support/Encrypt/tmp.txt.enc")

        XCTAssertTrue(result)
        XCTAssertTrue(FileManager.default.fileExists(atPath: encryptedFileUrl.path))

        try FileManager.default.removeItem(at: encryptedFileUrl)
    }

    func test_encryptDirectory() throws {
        let target: URL = URL(fileURLWithPath: "Tests/Support/Encrypt/logs", isDirectory: true)
        let result: Bool = encrypt(
            target: target,
            keyFile: keyFileUrl,
            encryptionType: .aes,
            isDirectory: true,
            mode: .encrypt
        )
        guard
            let enumerator: FileManager.DirectoryEnumerator = FileManager.default.enumerator(
                at: target,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [
                    .skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants,
                ]
            )
        else {
            XCTAssert(false, "Failed to make enumerator")
            return
        }

        let removeFile1: URL = URL(fileURLWithPath: "Tests/Support/Encrypt/logs/foo.log.enc")
        let removeFile2: URL = URL(fileURLWithPath: "Tests/Support/Encrypt/logs/bar.log.enc")

        XCTAssertTrue(result)
        XCTAssertNotNil(enumerator)
        XCTAssertEqual(enumerator.allObjects.count, 4)

        try FileManager.default.removeItem(at: removeFile1)
        try FileManager.default.removeItem(at: removeFile2)
    }
}
