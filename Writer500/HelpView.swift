//
//  HelpView.swift
//  Writer500
//
//  Created by Matt Gay on 1/3/26.
//

import SwiftUI
import Textual

private func loadHelpMarkdown() -> String {
    guard let url = Bundle.main.url(forResource: "HELP", withExtension: "md") else {
        return "Unable to find HELP.md in the app bundle.\n\nIn Xcode, ensure HELP.md is added to the Writer500 target and included in Copy Bundle Resources."
    }

    do {
        return try String(contentsOf: url, encoding: .utf8)
    } catch {
        return "Unable to read HELP.md (\(error.localizedDescription))."
    }
}

struct HelpView: View {
    @State private var markdown: String = ""

    var body: some View {
        ScrollView {
            StructuredText(markdown: markdown.isEmpty ? loadHelpMarkdown() : markdown)
                .textSelection(.enabled)
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minWidth: 520, minHeight: 520)
        .onAppear {
            if markdown.isEmpty {
                markdown = loadHelpMarkdown()
            }
        }
    }
}
