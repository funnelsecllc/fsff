# fsff - FunnelSec FunnelFiles

[![HitCount](https://hits.dwyl.com/funnelsecllc/fsff.svg?style=flat)](http://hits.dwyl.com/funnelsecllc/fsff)
![Static Badge](https://img.shields.io/badge/swift_tools_version-6.0-orange)
![GitHub License](https://img.shields.io/github/license/funnelsecllc/fsff)
![GitHub Release](https://img.shields.io/github/v/release/funnelsecllc/fsff)
![GitHub Downloads (all assets, latest release)](https://img.shields.io/github/downloads/funnelsecllc/fsff/latest/total)
![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/funnelsecllc/fsff/total)

A security CLI utility for file operations.

## Requirements

- macOS or Linux
- Swift installed on your machine
  - You can install a Swift version manager like [swiftly](https://github.com/swiftlang/swiftly)
  - Currently built with Swift version 6.0.1
- Swift tools version 6.0

## Building from source

1. Clone the repository `git clone https://github.com/funnelsecllc/fsff`
2. Navigate to the project directory `cd fsff`
3. Run `swift build -c release`
4. Copy the binary file to a location in your PATH `cp .build/release/fsff ~/.local/bin`

## Usage

### Arguments

- path: Path of the file or directory to be processed

### Options

- mode: -m --mode [hash]

### Examples

- Get help:

```bash
fsff -h
fsff --help
```

- Get hashes of a file

```bash
fsff Tests/Support/test.txt -m hash
MD5: 652df9705b9f52aa8ab873ae249d5e13
SHA1: bdffb172ae10700187e55d52d6c825d6b9874bbb
SHA256: bf73d81371ea21348bfb510d8c8948bb64e0eb3cea97ec991a4170e777b6de18
SHA384: 06687bda44e14e677b7bad7558ba483b9a9441e238c757fb24e2594a4d8c2721edc8af477d5710b4e6e7e27ca1b84640
SHA512: 5f80013bbe9684d3069c3025189ec35e8c8e1d73089963b6b19c01f71081df3113e10dbd5c83a459dd2ba5814932cab156a6fd11938ec26120606bf4ae5b242f
```

## Run tests

```bash
swift test
```

## License

MIT License

Copyright (c) 2024 FunnelSec LLC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
