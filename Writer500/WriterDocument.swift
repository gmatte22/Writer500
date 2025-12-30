//
//  WriterDocument.swift
//  Writer500
//
//  Created by Matt Gay on 12/29/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct WriterDocument: FileDocument {
    // What kinds of files this app can open
    static var readableContentTypes: [UTType] { [.plainText] }

    // The data your document contains (for now: just text)
    var text: String = ""

    // New empty document
    init() {}

    // Load an existing file into memory
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let str = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = str
    }

    // Save the in-memory document to disk
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8) ?? Data()
        return FileWrapper(regularFileWithContents: data)
    }
}
