import SwiftUI

/// Role: Field. Named colours from Assets.xcassets. Views reach tokens only through this accessor.
enum FieldInk {
    /// Screen background. Token #FAF7F5.
    static var background: Color { Color("background") }
    /// Cards, rows, sheets. Token #FEFEFD.
    static var surface: Color { Color("surface") }
    /// Primary text and icons. Token #392818.
    static var ink: Color { Color("ink") }
    /// Primary action, key figure, progress fill. Token #CC6D19.
    static var accent: Color { Color("accent") }
    /// Secondary text, dividers, disabled. Token #816C5A.
    static var muted: Color { Color("muted") }
}

/// Role: Field. SF Pro via Font.system. Six steps: display, title, headline, body, caption, micro. Display is Lodge, never above 34pt, never below 12pt.
enum FieldFace {
    static let face = "SF Pro"

    enum Step: CaseIterable {
        case display
        case title
        case headline
        case body
        case caption
        case micro
    }

    static func font(_ step: Step, size: DynamicTypeSize = .large) -> Font {
        switch step {
        case .display:
            if size >= .accessibility3 {
                return .system(.title2, design: .default).weight(.semibold).leading(.tight)
            }
            return .system(.title, design: .default).weight(.semibold).leading(.tight)
        case .title:
            return .system(.title3, design: .default).weight(.semibold).leading(.tight)
        case .headline:
            return .system(.headline, design: .default).weight(.semibold)
        case .body:
            return .system(.body, design: .default)
        case .caption:
            return .system(.footnote, design: .default).weight(.medium)
        case .micro:
            return .system(.caption, design: .default)
        }
    }

    static func verb(size: DynamicTypeSize) -> Font {
        if size >= .accessibility3 {
            return font(.headline, size: size)
        }
        if size >= .accessibility1 {
            return font(.title, size: size)
        }
        return font(.display, size: size)
    }
}
