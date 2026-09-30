import AppIntents
import Foundation

/// Role: Field. App Intents open Quiz, Explore, Saved, or Settings, or fire cutTondo or lodgeGround in place.
struct FieldQuizIntent: AppIntent {
    static var title: LocalizedStringResource { "Open Quiz" }
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        FieldPost.broadcast(.quiz)
        return .result()
    }
}

struct FieldExploreIntent: AppIntent {
    static var title: LocalizedStringResource { "Open Explore" }
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        FieldPost.broadcast(.explore)
        return .result()
    }
}

struct FieldSavedIntent: AppIntent {
    static var title: LocalizedStringResource { "Open Saved" }
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        FieldPost.broadcast(.saved)
        return .result()
    }
}

struct FieldSettingsIntent: AppIntent {
    static var title: LocalizedStringResource { "Open Settings" }
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        FieldPost.broadcast(.settings)
        return .result()
    }
}

struct CutTondoIntent: AppIntent {
    static var title: LocalizedStringResource { "Cut a tondo" }
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        FieldPost.broadcast(.cut)
        return .result()
    }
}

struct LodgeGroundIntent: AppIntent {
    static var title: LocalizedStringResource { "Lodge the tondo" }
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        FieldPost.broadcast(.lodge)
        return .result()
    }
}

struct FieldShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: FieldQuizIntent(),
            phrases: [
                "Open Quiz in \(.applicationName)",
                "Lodge the tondo in \(.applicationName)",
            ],
            shortTitle: "Quiz",
            systemImageName: "circle.dashed"
        )
        AppShortcut(
            intent: FieldExploreIntent(),
            phrases: [
                "Open Explore in \(.applicationName)",
            ],
            shortTitle: "Explore",
            systemImageName: "magnifyingglass"
        )
        AppShortcut(
            intent: FieldSavedIntent(),
            phrases: [
                "Open Saved in \(.applicationName)",
            ],
            shortTitle: "Saved",
            systemImageName: "bookmark"
        )
        AppShortcut(
            intent: FieldSettingsIntent(),
            phrases: [
                "Open Settings in \(.applicationName)",
            ],
            shortTitle: "Settings",
            systemImageName: "gearshape"
        )
        AppShortcut(
            intent: CutTondoIntent(),
            phrases: [
                "Cut a tondo in \(.applicationName)",
            ],
            shortTitle: "Cut",
            systemImageName: "scissors"
        )
        AppShortcut(
            intent: LodgeGroundIntent(),
            phrases: [
                "Lodge the tondo in \(.applicationName)",
            ],
            shortTitle: "Lodge",
            systemImageName: "checkmark"
        )
    }
}
