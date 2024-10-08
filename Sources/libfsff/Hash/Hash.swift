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

///  Method to get the hashes of a file or directory
/// - Parameter filePath: The path of the file or directory to get the hashes from
/// - Returns: List of hashes
public func getFileHashes(from filePath: URL) -> [String] {
    var results: [String] = []

    do {
        // Get the hashes of the file or directory
        let fileData: Data = try Data(contentsOf: filePath)
        let sha256Data: SHA256.Digest = SHA256.hash(data: fileData)
        let sha384Data: SHA384.Digest  = SHA384.hash(data: fileData)
        let sha512Data: SHA512.Digest = SHA512.hash(data: fileData)
        let md5Data: Insecure.MD5.Digest = Insecure.MD5.hash(data: fileData)
        let sha1Data: Insecure.SHA1.Digest = Insecure.SHA1.hash(data: fileData)
    
        // Convert the data to a string and add it to results
        let md5String: String = String("MD5: \(md5Data.compactMap { String(format:"%02x", $0)}.joined())")
        let sha1String: String = String("SHA1: \(sha1Data.compactMap { String(format:"%02x", $0)}.joined())")
        let sha256String: String = String("SHA256: \(sha256Data.compactMap { String(format:"%02x", $0) }.joined())")
        let sha384String: String = String("SHA384: \(sha384Data.compactMap { String(format:"%02x", $0) }.joined())")
        let sha512String: String = String("SHA512: \(sha512Data.compactMap { String(format:"%02x", $0) }.joined())")

        results = [md5String, sha1String, sha256String, sha384String, sha512String]
    } catch (let err) {
        print(err)
        
        print("Failed to get hashes")
        return []
    }

    return results
}

public func compareHashes(target1: URL, target2: URL) -> Bool {
    let target1Hashes: [String] = getFileHashes(from: target1)
    let target2Hashes: [String] = getFileHashes(from: target2)

    if target1Hashes.isEmpty || target2Hashes.isEmpty {
        return false;
    }

    let target1Sha512Hash: String.SubSequence = target1Hashes.last!.split(separator: " ")[1]
    let target2Sha512Hash: String.SubSequence = target2Hashes.last!.split(separator: " ")[1]

    return target1Sha512Hash == target2Sha512Hash
}
