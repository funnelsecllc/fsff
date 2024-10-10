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

///  Method to decrypt data with aes
/// - Parameters:
///   - sealedBox: The encrypted data to decrypt
///   - key: The key that was used to encrypt the data
/// - Throws: AES.GCM.open Error
/// - Returns: The decrypted data
private func aesGCMDecryption(with sealedBox: AES.GCM.SealedBox, key: SymmetricKey) throws -> Data {
    return try AES.GCM.open(sealedBox, using: key)
}

///  Method to decrypt data with chachapoly
/// - Parameters:
///   - sealedBox: The encrypted data to decrypt
///   - key: The key used to encrypted the data
/// - Throws: ChaChaPoly.open
/// - Returns: The decrypted data
private func chaChaPolyDecryption(
    with sealedBox: ChaChaPoly.SealedBox,
    key: SymmetricKey
) throws -> Data {
    return try ChaChaPoly.open(sealedBox, using: key)
}

///  Method to save the decrypted data to file
/// - Parameters:
///   - data: The decrypted data to save
///   - fileData: The file url object to save data into
/// - Returns: True if the file was created otherwise false
private func saveDecryptedData(with data: Data, fileUrl: URL) -> Bool {
    return FileManager.default.createFile(atPath: fileUrl.path, contents: data)
}

///  Method to facilitate the operations for decrypting files
/// - Parameters:
///   - file: The target file to decrypt
///   - keyFile: The key files used for decrypting
///   - encryptionType: The encryption method to use
///   - isDirectory: Whether or not to encrypt a directory.
/// - Returns: True if the process was successful otherwise false
public func decrypt(
    target: URL, 
    keyFile: URL, 
    encryptionType: EncryptionType, 
    isDirectory: Bool, 
    mode: Mode
)
    -> Bool
{
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

    // Attempt to decrypt file
    do {
        if isDirectory {
            for fileUrl: URL in subFiles {
                let content: Data = try Data(contentsOf: fileUrl)
                let newPath: String = fileUrl.path.replacingOccurrences(of: ".enc", with: "")
                let decryptedFileUrl: URL = URL(fileURLWithPath: newPath)

                // Encrypted the contents of the directory
                if encryptionType == .aes {
                    let sealedBox: AES.GCM.SealedBox = try AES.GCM.SealedBox(combined: content)
                    let encryptedData: Data = try aesGCMDecryption(with: sealedBox, key: key)
                    let saveSuccessful: Bool = saveDecryptedData(
                        with: encryptedData,
                        fileUrl: decryptedFileUrl
                    )
                    encryptionStatuses.append(saveSuccessful)
                } else {
                    let sealedBox: ChaChaPoly.SealedBox = try ChaChaPoly.SealedBox(
                        combined: content)
                    let encryptedData: Data = try chaChaPolyDecryption(with: sealedBox, key: key)
                    let saveSuccessful: Bool = saveDecryptedData(
                        with: encryptedData,
                        fileUrl: decryptedFileUrl
                    )
                    encryptionStatuses.append(saveSuccessful)
                }
            }

            // Check for any failed attempts
            let failCount: Int = encryptionStatuses.filter { $0 == false }.count
            if failCount != 0 {
                print("Failed to decrypt \(failCount) files.")
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

        let newPath: String = target.path.replacingOccurrences(of: ".enc", with: "")
        let decryptedFileUrl: URL = URL(fileURLWithPath: newPath)

        // Attempt to encrypt the target file
        if encryptionType == .aes {
            let sealedBox: AES.GCM.SealedBox = try AES.GCM.SealedBox(combined: fileContents)
            let encryptedData: Data = try aesGCMDecryption(with: sealedBox, key: key)

            return saveDecryptedData(with: encryptedData, fileUrl: decryptedFileUrl)
        } else {
            let sealedBox: ChaChaPoly.SealedBox = try ChaChaPoly.SealedBox(combined: fileContents)
            let encryptedData: Data = try chaChaPolyDecryption(with: sealedBox, key: key)

            return saveDecryptedData(with: encryptedData, fileUrl: decryptedFileUrl)
        }
    } catch {
        print("Unable to decrypt file.")
        return false
    }
}
