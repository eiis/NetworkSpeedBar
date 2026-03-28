import Combine
import Foundation

enum RefreshIntervalOption: String, CaseIterable, Identifiable {
    case halfSecond = "0.5"
    case oneSecond = "1.0"
    case twoSeconds = "2.0"

    var id: String { rawValue }

    var timeInterval: TimeInterval {
        switch self {
        case .halfSecond:
            return 0.5
        case .oneSecond:
            return 1.0
        case .twoSeconds:
            return 2.0
        }
    }

    var title: String {
        switch self {
        case .halfSecond:
            return "0.5 秒"
        case .oneSecond:
            return "1 秒"
        case .twoSeconds:
            return "2 秒"
        }
    }
}

enum DisplayUnitPreference: String, CaseIterable, Identifiable {
    case automatic
    case kilobytes
    case megabytes

    var id: String { rawValue }

    var title: String {
        switch self {
        case .automatic:
            return "自动"
        case .kilobytes:
            return "固定为 KB/s"
        case .megabytes:
            return "固定为 MB/s"
        }
    }
}

final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var refreshInterval: RefreshIntervalOption {
        didSet {
            defaults.set(refreshInterval.rawValue, forKey: Keys.refreshInterval)
        }
    }

    @Published var displayUnit: DisplayUnitPreference {
        didSet {
            defaults.set(displayUnit.rawValue, forKey: Keys.displayUnit)
        }
    }

    private let defaults: UserDefaults

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        refreshInterval = RefreshIntervalOption(
            rawValue: defaults.string(forKey: Keys.refreshInterval) ?? ""
        ) ?? .oneSecond
        displayUnit = DisplayUnitPreference(
            rawValue: defaults.string(forKey: Keys.displayUnit) ?? ""
        ) ?? .automatic
    }
}

private enum Keys {
    static let refreshInterval = "settings.refreshInterval"
    static let displayUnit = "settings.displayUnit"
}
