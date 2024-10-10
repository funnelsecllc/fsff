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

import Crypto
import Foundation

///  Method to create a key file 
/// - Parameters:
///   - size: The bit size of the key
///   - file: The file to save the key file as
/// - Returns: True if the key file was created successfully otherwise false
public func generateKey(with size: Size, to file: URL) -> Bool {
    let key: SymmetricKey

    // Create the key based on the bit size
    switch size {
    case .bits128:
        key = SymmetricKey(size: .bits128)
        break
    case .bits192:
        key = SymmetricKey(size: .bits192)
        break
    case .bits256:
        key = SymmetricKey(size: .bits256)
        break
    }

    // Save key file to desired name
    return FileManager.default.createFile(
        atPath: file.path, 
        contents: key.withUnsafeBytes { Data($0) }
    )
}
