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

///  Method to encrypt data with aes
/// - Parameters:
///   - data: The data to encrypt
///   - key: The key to encrypt the data with
/// - Throws: AES.GCM.seal Error
/// - Returns: The encrypted data
private func aesGCMEncryption(with data: Data, key: SymmetricKey) throws -> Data? {
    return try AES.GCM.seal(data, using: key).combined
}

///  Method to encrypt data with chachapoly
/// - Parameters:
///   - data: The data to encrypt
///   - key: The key to encrypt the data with
/// - Throws: ChaChaPoly.seal Error
/// - Returns: The encrypted data
private func chaChaPolyEncryption(with data: Data, key: SymmetricKey) throws -> Data {
    return try ChaChaPoly.seal(data, using: key).combined
}

///  Method to save the encryted data to file
/// - Parameters:
///   - data: The encrypted data to save
///   - fileUrl: The file url object to store data into
/// - Returns: True if the file was created along with the data otherwise false
private func saveEncryptedData(with data: Data, fileUrl: URL) -> Bool {
    return FileManager.default.createFile(
        atPath: fileUrl.path + ".enc",
        contents: data
    )
}

///  Method to facilitate the operations for encrypting files
/// - Parameters:
///   - file: The target file to encrypt
///   - keyFile: The key file to use for encrypting
///   - encryptionType: The encryption method to use
///   - isDirectory: Whether or not to encrypt a directory.
///   - mode: The mode to use for the encryption.
/// - Returns: True if the process was succesful otherwise false
public func encrypt(
    target: URL,
    keyFile: URL,
    encryptionType: EncryptionType,
    isDirectory: Bool,
    mode: Mode
) -> Bool {
    let keyData: Data
    let key: SymmetricKey
    let fileContents: Data
    var subFiles: [URL] = []
    var encryptionStatuses: [Bool] = []

    // Ensure that the key file can be read
    do {
        keyData = try Data(contentsOf: keyFile)
        key = SymmetricKey(data: keyData)
    } catch {
        print("Invalid key file.")
        return false
    }

    // Get all the files in the target directory
    if isDirectory {
        subFiles = getDirectoryFiles(from: target, mode: mode)
    }

    // Attempt to encrypt files in directory
    do {
        if isDirectory {
            for fileUrl: URL in subFiles {
                let content: Data = try Data(contentsOf: fileUrl)

                // Encrypted the contents of the directory
                if encryptionType == .aes {
                    guard let encryptedData: Data = try aesGCMEncryption(with: content, key: key)
                    else {
                        continue
                    }

                    let saveSuccessful: Bool = saveEncryptedData(
                        with: encryptedData,
                        fileUrl: fileUrl
                    )
                    print("Encrypting \(fileUrl.path): \(saveSuccessful)")
                    encryptionStatuses.append(saveSuccessful)
                } else {
                    let encryptedData: Data = try chaChaPolyEncryption(with: content, key: key)
                    let saveSuccessful: Bool = saveEncryptedData(
                        with: encryptedData,
                        fileUrl: fileUrl
                    )
                    encryptionStatuses.append(saveSuccessful)
                }
            }

            // Check for any failed attempts
            let failCount: Int = encryptionStatuses.filter { $0 == false }.count
            if failCount != 0 {
                print("Failed to encrypt \(failCount) files.")
                return false
            }
            return true
        }

        // Ensure that the target file can be read
        do {
            fileContents = try Data(contentsOf: target)
        } catch {
            print("Unable to read target file.")
            return false
        }

        // Attempt to encrypt the target file
        if encryptionType == .aes {
            guard let encryptedData: Data = try aesGCMEncryption(with: fileContents, key: key)
            else {
                return false
            }
            return saveEncryptedData(with: encryptedData, fileUrl: target)
        } else {
            let encryptedData: Data = try chaChaPolyEncryption(with: fileContents, key: key)
            return saveEncryptedData(with: encryptedData, fileUrl: target)
        }
    } catch {
        print("Unable to encrypt file.")
        return false
    }
}
