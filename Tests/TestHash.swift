import XCTest
@testable import libfsff

let file: URL = URL(fileURLWithPath: "Tests/Support/test.txt")

class TestHash: XCTestCase {
    func test_getFileHashes() {
        let hashes: [String] = getFileHashes(from: file)
        XCTAssertFalse(hashes.isEmpty)
    }

    func test_nonExisitingFile() {
        let nonExisting: URL = URL(fileURLWithPath: "Tests/Support/non-existing")
        let hashes: [String] = getFileHashes(from: nonExisting)
        XCTAssertTrue(hashes.isEmpty)
    }

    func test_matchingHashValues() {
        let hashes: [String] = getFileHashes(from: file)
        let md5Hash: String.SubSequence = hashes[0].split(separator: " ")[1]
        let sha1Hash: String.SubSequence = hashes[1].split(separator: " ")[1]
        let sha256Hash: String.SubSequence = hashes[2].split(separator: " ")[1]
        let sha384Hash: String.SubSequence = hashes[3].split(separator: " ")[1]
        let sha512Hash: String.SubSequence = hashes[4].split(separator: " ")[1]

        XCTAssert(md5Hash == "652df9705b9f52aa8ab873ae249d5e13")
        XCTAssert(sha1Hash == "bdffb172ae10700187e55d52d6c825d6b9874bbb")
        XCTAssert(sha256Hash == "bf73d81371ea21348bfb510d8c8948bb64e0eb3cea97ec991a4170e777b6de18")
        XCTAssert(sha384Hash == "06687bda44e14e677b7bad7558ba483b9a9441e238c757fb24e2594a4d8c2721edc8af477d5710b4e6e7e27ca1b84640")
        XCTAssert(sha512Hash == "5f80013bbe9684d3069c3025189ec35e8c8e1d73089963b6b19c01f71081df3113e10dbd5c83a459dd2ba5814932cab156a6fd11938ec26120606bf4ae5b242f")
    }

    func test_compareHashesBetweenTwoFiles() {
        let isSameHash: Bool = compareHashes(target1: file, target2: file)
        XCTAssertTrue(isSameHash)
    }

    func test_compareHashesBetweenDifferentFiles() {
        let file2: URL = URL(fileURLWithPath: "Tests/Support/exam.txt")
        let isSameHash: Bool = compareHashes(target1: file, target2: file2)
        XCTAssertFalse(isSameHash)
    }
}
