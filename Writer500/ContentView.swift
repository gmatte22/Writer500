//
//  ContentView.swift
//  Writer500
//
//  Created by Matt Gay on 12/29/25.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: WriterDocument
    
    private var wordCount: Int {
        // Word count rules:
        // - A single '-' joins two strings into one word ("well-being" counts as 1).
        // - Any run of 2+ '-' ("--", "---") acts like an em dash and splits words.
        // - En dash (–) and em dash (—) split words.

        // Normalize all dash-like separators that should split words into spaces:
        //   • em dash (—)
        //   • en dash (–)
        //   • double (or more) hyphen-minus (--) / (---) etc.
        let dashSeparated = document.text
            .replacingOccurrences(of: "—", with: " ")
            .replacingOccurrences(of: "–", with: " ")
            .replacingOccurrences(of: "--", with: " ")

        // Replace any remaining 2+ hyphen runs that weren't fully handled above.
        // Doing this without regex keeps it readable: collapse sequences by repeatedly
        // removing any newly formed "--" after the first pass.
        var normalized = dashSeparated
        while normalized.contains("--") {
            normalized = normalized.replacingOccurrences(of: "--", with: " ")
        }

        // Split on whitespace/newlines. Single hyphens remain inside tokens and
        // therefore keep hyphenated words intact.
        let tokens = normalized.split { $0.isWhitespace || $0.isNewline }
        return tokens.count
    }
    
    // Configurable word limit persisted across app launches
    @AppStorage("wordLimit") private var wordLimit: Int = 500

    // Configurable editor font size persisted across app launches
    @AppStorage("editorFontSize") private var editorFontSize: Double = 16

    // Focus mode dims UI chrome to keep attention on the editor
    @AppStorage("focusMode") private var focusMode: Bool = false

    // Text field editing state for the word limit
    @State private var wordLimitText: String = ""
    @FocusState private var isLimitFieldFocused: Bool

    @State private var isHoveringBottomBar: Bool = false

    private func clampedWordLimit(_ value: Int) -> Int {
        // Keep it in a sane range for now. Adjust later if you want.
        min(10000, max(1, value))
    }
    
    private var remainingWords: Int {
        max(0, wordLimit - wordCount)
    }
    
    private var isOverLimit: Bool {
        wordCount > wordLimit
    }
    
    private var progressValue: Double {
        guard wordLimit > 0 else { return 0 }
        return min(1.0, Double(wordCount) / Double(wordLimit))
    }

    private var overLimitCount: Int {
        max(0, wordCount - wordLimit)
    }

    private var progressTint: Color {
        if isOverLimit {
            return .red
        }

        // 0% -> green (~120°), 70% -> yellow (~60°), 100% -> orange (~30°)
        let greenHue: Double = 1.0 / 3.0       // 0.333...
        let yellowHue: Double = 1.0 / 6.0      // 0.166...
        let orangeHue: Double = 1.0 / 12.0     // 0.0833...

        let p = max(0.0, min(1.0, progressValue))
        let hue: Double

        if p <= 0.7 {
            let t = p / 0.7
            hue = greenHue + (yellowHue - greenHue) * t
        } else {
            let t = (p - 0.7) / 0.3
            hue = yellowHue + (orangeHue - yellowHue) * t
        }

        return Color(hue: hue, saturation: 0.95, brightness: 0.95)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TextEditor(text: $document.text)
                .font(.system(size: editorFontSize))
                .padding()

            HStack(spacing: 10) {
                Text("Goal: ")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.primary)

                TextField("", text: $wordLimitText)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 70)
                    .font(.system(size: 13))
                    .focused($isLimitFieldFocused)
                    .onSubmit {
                        // Apply on Return/Enter
                        if let n = Int(wordLimitText.trimmingCharacters(in: .whitespacesAndNewlines)) {
                            wordLimit = clampedWordLimit(n)
                        } else {
                            // Revert if invalid
                            wordLimitText = String(wordLimit)
                        }
                    }
                    .onChange(of: isLimitFieldFocused) { _, focused in
                        // If the user clicks away, apply the value just like pressing Return.
                        guard focused == false else { return }
                        let trimmed = wordLimitText.trimmingCharacters(in: .whitespacesAndNewlines)
                        if let n = Int(trimmed) {
                            wordLimit = clampedWordLimit(n)
                        } else {
                            wordLimitText = String(wordLimit)
                        }
                    }

                Text("Written Words: \(wordCount)")
                    .font(.system(size: 12, weight: .medium))
                    .monospacedDigit()
                    .foregroundStyle(.primary)

                ProgressView(value: progressValue)
                    .tint(progressTint)
                    .frame(maxWidth: .infinity)
                    .animation(.easeOut(duration: 0.15), value: progressValue)

                if isOverLimit {
                    Text("Over: \(overLimitCount)")
                        .font(.system(size: 12, weight: .medium))
                        .monospacedDigit()
                        .foregroundStyle(.red)
                } else {
                    Text("Remaining: \(remainingWords)")
                        .font(.system(size: 12, weight: .medium))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .opacity(focusMode ? (isHoveringBottomBar ? 1.0 : 0.15) : 1.0)
            .onHover { hovering in
                isHoveringBottomBar = hovering
            }
        }
        .onAppear {
            wordLimitText = String(wordLimit)
        }
        .onChange(of: wordLimit) { _, newValue in
            let n = clampedWordLimit(newValue)
            if n != newValue {
                wordLimit = n
                return
            }
            // Keep the text field synced unless the user is actively editing it.
            if !isLimitFieldFocused {
                wordLimitText = String(newValue)
            }
        }
    }
}

#Preview {
    ContentView(document: .constant(WriterDocument()))
        .frame(width: 600, height: 400)
}
