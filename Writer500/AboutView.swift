//
//  AboutView.swift
//  Writer500
//
//  Created by Matt Gay on 12/29/25.
//

import SwiftUI

struct AboutView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Writer500")
                .font(.title2)
                .bold()

            Text("Version \(appVersion)")
                .font(.subheadline)

            Text("Developed by Matt Gay\nSuggestions and feedback are welcome")
                .font(.body)
                .foregroundStyle(.secondary)

            Divider()

            Text("What's New")
                .font(.headline)

            if let changelogDate = changelogModifiedDate {
                Text("Changelog last updated: \(changelogDate)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ScrollView {
                Text(changelogText)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(minHeight: 220)

            Spacer(minLength: 0)
        }
        .padding(18)
        .padding(.top, 50)
        .frame(width: 520, height: 360)
    }

    // MARK: - Private helpers

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
    }

    private var changelogText: String {
        // Loads CHANGELOG.txt shipped inside the app bundle.
        // If the file is missing, we show a helpful fallback message.
        guard let url = Bundle.main.url(forResource: "CHANGELOG", withExtension: "txt") else {
            return "CHANGELOG.txt not found in app bundle.\n\nIn Xcode: add a file named CHANGELOG.txt to the project and make sure it's included in the Writer500 target."
        }

        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            return "Unable to read CHANGELOG.txt (\(error.localizedDescription))."
        }
    }

    private var changelogModifiedDate: String? {
        guard let url = Bundle.main.url(forResource: "CHANGELOG", withExtension: "txt") else {
            return nil
        }

        do {
            let values = try url.resourceValues(forKeys: [.contentModificationDateKey])
            guard let date = values.contentModificationDate else { return nil }

            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } catch {
            return nil
        }
    }
}
