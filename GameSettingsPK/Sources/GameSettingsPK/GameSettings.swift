// Game Settings
import Foundation

public enum Setting: CaseIterable, Hashable, Sendable {
    case sound
    case music
    case haptic
    case darkMode
    case showHints
}

public enum Preference: Codable, Equatable, Sendable {
    case sound(enabled: Bool)
    case music(enabled: Bool)
    case haptic(enabled: Bool)
    case darkMode(enabled: Bool)
    case showHints(enabled: Bool)

    public var setting: Setting {
        switch self {
        case .sound: .sound
        case .music: .music
        case .haptic: .haptic
        case .darkMode: .darkMode
        case .showHints: .showHints
        }
    }

    public var isEnabled: Bool {
        switch self {
        case let .sound(enabled),
             let .music(enabled),
             let .haptic(enabled),
             let .darkMode(enabled),
             let .showHints(enabled):
            enabled
        }
    }
}

public actor GameSettings {
    private var enabledSettings: Set<Setting>

    public init(enabledSettings: Set<Setting> = []) {
        self.enabledSettings = enabledSettings
    }

    public func isEnabled(_ setting: Setting) -> Bool {
        enabledSettings.contains(setting)
    }

    @discardableResult
    public func toggle(_ setting: Setting) -> Bool {
        if enabledSettings.remove(setting) != nil {
            return false
        }
        enabledSettings.insert(setting)
        return true
    }

    public func setEnabled(_ isEnabled: Bool, for setting: Setting) {
        if isEnabled {
            enabledSettings.insert(setting)
        } else {
            enabledSettings.remove(setting)
        }
    }

    public var preferences: [Preference] {
        Setting.allCases.map { setting in
            let isEnabled = enabledSettings.contains(setting)
            switch setting {
            case .sound: return .sound(enabled: isEnabled)
            case .music: return .music(enabled: isEnabled)
            case .haptic: return .haptic(enabled: isEnabled)
            case .darkMode: return .darkMode(enabled: isEnabled)
            case .showHints: return .showHints(enabled: isEnabled)
            }
        }
    }
}
