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

class TestDecryption: XCTestCase {
    let keyFileUrl: URL = URL(fileURLWithPath: "Tests/Support/test.key")

    func test_decryptFile() throws {
        let target: URL = URL(fileURLWithPath: "Tests/Support/Decrypt/tmp.txt.enc")
        let result: Bool = decrypt(
            target: target,
            keyFile: keyFileUrl,
            encryptionType: .aes,
            isDirectory: false,
            mode: .decrypt
        )
        let decryptedFileUrl: URL = URL(fileURLWithPath: "Tests/Support/Decrypt/tmp.txt")

        XCTAssertTrue(result)
        XCTAssertTrue(FileManager.default.fileExists(atPath: decryptedFileUrl.path))

        let content: String = try String(contentsOf: decryptedFileUrl, encoding: .utf8)
        XCTAssertEqual(content, "Hello world")

        try FileManager.default.removeItem(at: decryptedFileUrl)
    }

    func test_decryptDirectory() throws {
        let target: URL = URL(fileURLWithPath: "Tests/Support/Decrypt/logs")
        let result: Bool = decrypt(
            target: target,
            keyFile: keyFileUrl,
            encryptionType: .aes,
            isDirectory: true,
            mode: .decrypt
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

        let removeFile1: URL = URL(fileURLWithPath: "Tests/Support/Decrypt/logs/foo.log")
        let removeFile2: URL = URL(fileURLWithPath: "Tests/Support/Decrypt/logs/bar.log")

        XCTAssertTrue(result)
        XCTAssertNotNil(enumerator)
        XCTAssertEqual(enumerator.allObjects.count, 4)

        try FileManager.default.removeItem(at: removeFile1)
        try FileManager.default.removeItem(at: removeFile2)
    }
}
