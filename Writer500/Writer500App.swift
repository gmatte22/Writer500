//
//  Writer500App.swift
//  Writer500
//
//  Created by Matt Gay on 12/29/25.
//

import SwiftUI

@main
struct Writer500App: App {
    var body: some Scene {
        DocumentGroup(newDocument: WriterDocument()) { file in
            ContentView(document: file.$document)
        }
        .commands {
            Writer500Commands()
        }
    }
}

struct Writer500Commands: Commands {
    @AppStorage("editorFontSize") private var editorFontSize: Double = 16
    @AppStorage("wordLimit") private var wordLimit: Int = 500
    @AppStorage("focusMode") private var focusMode: Bool = false

    var body: some Commands {
        CommandGroup(after: .textEditing) {
            Divider()

            Button("Increase Font Size") {
                editorFontSize = min(editorFontSize + 1, 72)
            }
            .keyboardShortcut("+", modifiers: [.command])

            Button("Decrease Font Size") {
                editorFontSize = max(editorFontSize - 1, 8)
            }
            .keyboardShortcut("-", modifiers: [.command])

            Button("Reset Font Size") {
                editorFontSize = 16
            }
            .keyboardShortcut("0", modifiers: [.command])

            Divider()

            Button("Reset Defaults (16pt / 500 words)") {
                editorFontSize = 16
                wordLimit = 500
            }
            .keyboardShortcut("r", modifiers: [.command, .shift])
        }
        CommandMenu("View") {
            Button(focusMode ? "Disable Focus Mode" : "Enable Focus Mode") {
                focusMode.toggle()
            }
            .keyboardShortcut("f", modifiers: [.command, .shift])
        }
    }
}
