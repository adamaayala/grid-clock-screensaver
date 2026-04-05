import AppKit
import ScreenSaver

/// Programmatic replacement for ConfigureSheet.xib.
final class ConfigureSheetController {

    static let shared = ConfigureSheetController()

    let window: NSPanel
    private let popUpButton: NSPopUpButton

    private init() {
        // Panel
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 102),
            styleMask: [.titled],
            backing: .buffered,
            defer: true
        )
        panel.isReleasedWhenClosed = false

        let contentView = panel.contentView!

        // "Show on:" label
        let label = NSTextField(frame: NSRect(x: 20, y: 64, width: 60, height: 17))
        label.stringValue = "Show on:"
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        label.isSelectable = false
        label.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        contentView.addSubview(label)

        // Popup button
        let popup = NSPopUpButton(frame: NSRect(x: 84, y: 58, width: 219, height: 26), pullsDown: false)
        popup.addItems(withTitles: [
            "Primary Display",
            "Last Focussed Display",
            "All Displays"
        ])
        contentView.addSubview(popup)

        self.window = panel
        self.popUpButton = popup

        // Cancel button
        let cancelButton = NSButton(frame: NSRect(x: 144, y: 13, width: 81, height: 32))
        cancelButton.title = "Cancel"
        cancelButton.bezelStyle = .rounded
        cancelButton.keyEquivalent = "\u{1b}" // Escape
        cancelButton.target = self
        cancelButton.action = #selector(cancelClicked(_:))
        contentView.addSubview(cancelButton)

        // OK button
        let okButton = NSButton(frame: NSRect(x: 225, y: 13, width: 81, height: 32))
        okButton.title = "OK"
        okButton.bezelStyle = .rounded
        okButton.keyEquivalent = "\r" // Return
        okButton.target = self
        okButton.action = #selector(okClicked(_:))
        contentView.addSubview(okButton)

        // Load current value
        popup.selectItem(at: Preferences.displayOption.rawValue)
    }

    @objc private func cancelClicked(_ sender: Any) {
        // Reset to saved value
        popUpButton.selectItem(at: Preferences.displayOption.rawValue)
        closeSheet()
    }

    @objc private func okClicked(_ sender: Any) {
        if let option = DisplayOption(rawValue: popUpButton.indexOfSelectedItem) {
            Preferences.displayOption = option
        }
        closeSheet()
    }

    private func closeSheet() {
        guard let parent = window.sheetParent else { return }
        parent.endSheet(window)
    }
}
