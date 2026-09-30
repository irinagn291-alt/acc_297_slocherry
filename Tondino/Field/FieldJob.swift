import Foundation

/// Role: Field. Jobs for App Intents and tondino:// plus https://tondino-field.pro paths. Quiz stays put. No Game tab.
enum FieldJob: String, Equatable, Sendable {
    case quiz
    case explore
    case saved
    case settings
    case cut
    case lodge
    case twist

    static let httpsHost = "tondino-field.pro"

    static func parse(_ url: URL) -> FieldJob? {
        let scheme = url.scheme?.lowercased() ?? ""
        if scheme == "tondino" {
            let host = url.host?.lowercased() ?? ""
            let path = url.path.lowercased().trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            let token = host.isEmpty ? path : host
            return FieldJob(rawValue: token)
        }
        if scheme == "https", url.host?.lowercased() == httpsHost {
            let path = url.path.lowercased().trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            if path.isEmpty { return .quiz }
            return FieldJob(rawValue: path)
        }
        return nil
    }

    static func parse(notification: Notification) -> FieldJob? {
        guard let raw = notification.userInfo?[FieldPost.key] as? String else { return nil }
        return FieldJob(rawValue: raw)
    }

    var cover: FieldCover? {
        switch self {
        case .quiz, .cut, .lodge:
            return nil
        case .explore:
            return .explore
        case .saved:
            return .saved
        case .settings:
            return .settings
        case .twist:
            return .twist
        }
    }
}

/// Role: Field. Sheets over the locked Quiz field. Four destinations plus the cut-then-lodge fold screen.
enum FieldCover: String, Identifiable, Equatable, Sendable {
    case explore
    case saved
    case settings
    case twist

    var id: String { rawValue }
}

extension Notification.Name {
    static let fieldJob = Notification.Name("tnd.field.job")
}

enum FieldPost {
    static let key = "job"

    static func broadcast(_ job: FieldJob) {
        NotificationCenter.default.post(
            name: .fieldJob,
            object: nil,
            userInfo: [key: job.rawValue]
        )
    }
}
