import ScreenSaver
import AppKit

@objc(GridClockView)
final class GridClockView: ScreenSaverView {

    private let gridRenderer = GridRenderer()
    private var currentPositions = Set<GridModel.Position>()
    private var isDisplayEnabled = false

    // MARK: - Init

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        commonInit(frame: frame, isPreview: isPreview)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    private func commonInit(frame: NSRect, isPreview: Bool) {
        animationTimeInterval = 1.0
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor

        guard shouldDisplay(frame: frame, isPreview: isPreview) else { return }

        isDisplayEnabled = true
        layer?.addSublayer(gridRenderer.containerLayer)
        gridRenderer.layout(in: bounds)
        updateClock()
    }

    // MARK: - ScreenSaverView

    override func animateOneFrame() {
        guard isDisplayEnabled else { return }
        updateClock()
    }

    override func resize(withOldSuperviewSize oldSize: NSSize) {
        super.resize(withOldSuperviewSize: oldSize)
        guard isDisplayEnabled else { return }
        gridRenderer.layout(in: bounds)
    }

    private func updateClock() {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)

        let newPositions = TimeEngine.activePositions(hour24: hour, minute: minute)
        guard newPositions != currentPositions else { return }

        currentPositions = newPositions
        gridRenderer.update(activePositions: newPositions)
    }

    // MARK: - Display Selection

    private func shouldDisplay(frame: NSRect, isPreview: Bool) -> Bool {
        if isPreview { return true }

        switch Preferences.displayOption {
        case .primaryDisplay:
            guard let primary = NSScreen.screens.first else { return true }
            return primary.frame.origin.x == frame.origin.x
        case .lastFocusedDisplay:
            guard let main = NSScreen.main else { return true }
            return main.frame.origin.x == frame.origin.x
        case .allDisplays:
            return true
        }
    }

    // MARK: - Configuration

    override var hasConfigureSheet: Bool { true }

    override var configureSheet: NSWindow? {
        ConfigureSheetController.shared.window
    }

    // MARK: - Focus Overrides

    override func hitTest(_ point: NSPoint) -> NSView? { self }
    override func mouseDown(with event: NSEvent) {}
    override func mouseUp(with event: NSEvent) {}
    override func mouseDragged(with event: NSEvent) {}
    override func mouseEntered(with event: NSEvent) {}
    override func mouseExited(with event: NSEvent) {}
    override var acceptsFirstResponder: Bool { true }
    override func resignFirstResponder() -> Bool { false }
}
