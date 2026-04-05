import ScreenSaver

enum DisplayOption: Int {
    case primaryDisplay = 0
    case lastFocusedDisplay = 1
    case allDisplays = 2
}

enum Preferences {
    static let moduleID = "com.adamayala.grid-clock"
    static let screenDisplayOptionKey = "screenDisplayOption"

    static var defaults: ScreenSaverDefaults? {
        let d = ScreenSaverDefaults(forModuleWithName: moduleID)
        d?.register(defaults: [screenDisplayOptionKey: DisplayOption.primaryDisplay.rawValue])
        return d
    }

    static var displayOption: DisplayOption {
        get {
            let raw = defaults?.integer(forKey: screenDisplayOptionKey) ?? 0
            return DisplayOption(rawValue: raw) ?? .primaryDisplay
        }
        set {
            defaults?.set(newValue.rawValue, forKey: screenDisplayOptionKey)
            defaults?.synchronize()
        }
    }
}
