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
            DocumentWindowRoot(document: file.$document)
        }
        .defaultSize(width: 900, height: 650)
        .commands {
            Writer500Commands()
        }

        Window("About Writer500", id: "about") {
            AboutView()
        }
        .windowResizability(.contentSize)

        Window("Writer500 Help", id: "help") {
                HelpView()
            }
        .windowResizability(.contentSize)
    }
}

struct Writer500Commands: Commands {
    @Environment(\.openWindow) private var openWindow
    @AppStorage("editorFontSize") private var editorFontSize: Double = 16
    @AppStorage("wordLimit") private var wordLimit: Int = 500
    @AppStorage("focusMode") private var focusMode: Bool = false

    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button("About Writer500") {
                openWindow(id: "about")
            }
        }
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

        CommandGroup(replacing: .help) {
            Button("Writer500 Help") {
                openWindow(id: "help")
            }
            .keyboardShortcut("?", modifiers: [.command])
        }
    }
}
