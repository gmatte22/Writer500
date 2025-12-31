//
//  WindowPersistence.swift
//  Writer500
//
//  Window sizing and position persistence for the document window.
//

import SwiftUI
import AppKit

// MARK: - Window sizing (default + remember last size)

struct DocumentWindowRoot: View {
    @Binding var document: WriterDocument

    // Persist the last window size the user set.
    @AppStorage("lastWindowWidth") private var lastWindowWidth: Double = 0
    @AppStorage("lastWindowHeight") private var lastWindowHeight: Double = 0
    @AppStorage("lastWindowX") private var lastWindowX: Double = 0
    @AppStorage("lastWindowY") private var lastWindowY: Double = 0

    var body: some View {
        ContentView(document: $document)
            // Hooks into the hosting NSWindow so we can apply / persist size.
            .background(WindowSizeTracker(
                initialSize: initialSize,
                initialOrigin: initialOrigin,
                onSizeChange: { size in
                    // Store only sensible values.
                    guard size.width >= 300, size.height >= 300 else { return }
                    lastWindowWidth = Double(size.width)
                    lastWindowHeight = Double(size.height)
                },
                onOriginChange: { origin in
                    // Persist window placement.
                    lastWindowX = Double(origin.x)
                    lastWindowY = Double(origin.y)
                }
            ))
    }

    private var initialSize: CGSize? {
        // If we've stored a previous size, use it.
        guard lastWindowWidth > 0, lastWindowHeight > 0 else { return nil }
        return CGSize(width: lastWindowWidth, height: lastWindowHeight)
    }

    private var initialOrigin: CGPoint? {
        // If we've stored a previous origin, use it.
        guard lastWindowX != 0 || lastWindowY != 0 else { return nil }
        return CGPoint(x: lastWindowX, y: lastWindowY)
    }
}

private struct WindowSizeTracker: NSViewRepresentable {
    var initialSize: CGSize?
    var initialOrigin: CGPoint?
    var onSizeChange: (CGSize) -> Void
    var onOriginChange: (CGPoint) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            initialSize: initialSize,
            initialOrigin: initialOrigin,
            onSizeChange: onSizeChange,
            onOriginChange: onOriginChange
        )
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        context.coordinator.attach(to: view)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        // Nothing to update.
    }

    final class Coordinator: NSObject {
        private let initialSize: CGSize?
        private let initialOrigin: CGPoint?
        private let onSizeChange: (CGSize) -> Void
        private let onOriginChange: (CGPoint) -> Void
        private weak var window: NSWindow?
        private var didApplyInitialSize = false
        private var observers: [NSObjectProtocol] = []

        init(
            initialSize: CGSize?,
            initialOrigin: CGPoint?,
            onSizeChange: @escaping (CGSize) -> Void,
            onOriginChange: @escaping (CGPoint) -> Void
        ) {
            self.initialSize = initialSize
            self.initialOrigin = initialOrigin
            self.onSizeChange = onSizeChange
            self.onOriginChange = onOriginChange
        }

        func attach(to view: NSView) {
            // Defer until the NSView has a window.
            DispatchQueue.main.async { [weak self, weak view] in
                guard let self, let view else { return }
                self.tryConnect(to: view)
            }
        }

        private func tryConnect(to view: NSView) {
            guard let window = view.window else {
                // Try again next run loop.
                DispatchQueue.main.async { [weak self, weak view] in
                    guard let self, let view else { return }
                    self.tryConnect(to: view)
                }
                return
            }

            // If we already connected to this window, nothing to do.
            if self.window === window { return }

            self.window = window
            self.installObservers(for: window)
            self.applyInitialSizeIfNeeded(to: window)
            self.applyInitialOriginIfNeeded(to: window)

            // Record current size immediately.
            self.onSizeChange(window.contentLayoutRect.size)
            self.onOriginChange(window.frame.origin)
        }

        private func applyInitialSizeIfNeeded(to window: NSWindow) {
            guard !didApplyInitialSize, let initialSize else { return }
            didApplyInitialSize = true

            // Set the content size so the window frame is adjusted appropriately.
            window.setContentSize(NSSize(width: initialSize.width, height: initialSize.height))
        }

        private func applyInitialOriginIfNeeded(to window: NSWindow) {
            guard let initialOrigin else { return }

            // Use the current frame size (already adjusted by setContentSize, if any).
            var frame = window.frame
            frame.origin = adjustedOrigin(desiredOrigin: initialOrigin, frameSize: frame.size)
            window.setFrame(frame, display: true)
        }

        private func adjustedOrigin(desiredOrigin: CGPoint, frameSize: CGSize) -> CGPoint {
            // Ensure the window isn't restored off-screen.
            let screens = NSScreen.screens
            let visibleFrames = screens.map { $0.visibleFrame }

            // Prefer the screen that contains the desired origin.
            let targetVisible = visibleFrames.first(where: { $0.contains(desiredOrigin) })
                ?? NSScreen.main?.visibleFrame
                ?? visibleFrames.first
                ?? NSRect(x: 0, y: 0, width: 1200, height: 800)

            // Clamp so the entire window remains within the visible frame.
            let minX = targetVisible.minX
            let maxX = targetVisible.maxX - frameSize.width
            let minY = targetVisible.minY
            let maxY = targetVisible.maxY - frameSize.height

            let clampedX = min(max(desiredOrigin.x, minX), maxX)
            let clampedY = min(max(desiredOrigin.y, minY), maxY)

            return CGPoint(x: clampedX, y: clampedY)
        }

        private func installObservers(for window: NSWindow) {
            // Clean up old observers.
            for obs in observers { NotificationCenter.default.removeObserver(obs) }
            observers.removeAll()

            let nc = NotificationCenter.default

            // Persist size whenever the window is resized (including live resize).
            observers.append(nc.addObserver(
                forName: NSWindow.didResizeNotification,
                object: window,
                queue: .main
            ) { [weak self, weak window] _ in
                guard let self, let window else { return }
                self.onSizeChange(window.contentLayoutRect.size)
            })

            // Also persist at the end of a live resize.
            observers.append(nc.addObserver(
                forName: NSWindow.didEndLiveResizeNotification,
                object: window,
                queue: .main
            ) { [weak self, weak window] _ in
                guard let self, let window else { return }
                self.onSizeChange(window.contentLayoutRect.size)
            })

            // Persist position whenever the window is moved.
            observers.append(nc.addObserver(
                forName: NSWindow.didMoveNotification,
                object: window,
                queue: .main
            ) { [weak self, weak window] _ in
                guard let self, let window else { return }
                self.onOriginChange(window.frame.origin)
            })
        }

        deinit {
            for obs in observers { NotificationCenter.default.removeObserver(obs) }
        }
    }
}
