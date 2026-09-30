import SwiftUI
import UIKit

/// Role: Field. One 8pt grid. Hits are 44pt. Views never pick a stray padding.
enum FieldPad {
    static let unit: CGFloat = 8

    static func step(_ n: Int) -> CGFloat {
        unit * CGFloat(n)
    }

    static var hit: CGFloat { 44 }
    static var outer: CGFloat { step(3) }
    static var card: CGFloat { step(2) }
    static var inner: CGFloat { step(1) }
    static var gap: CGFloat { step(1) }

    static func isWide(_ sizeClass: UserInterfaceSizeClass?) -> Bool {
        sizeClass == .regular || UIDevice.current.userInterfaceIdiom == .pad
    }
}

/// Role: Field. Cards 20pt, chips 12pt. Never a second radius language.
enum FieldCurve {
    static let card: CGFloat = 20
    static let chip: CGFloat = 12
}

/// Role: Field. One soft drop-shadow. Only the circular Shard wears it.
enum FieldLift {
    static let radius: CGFloat = 16
    static let y: CGFloat = 8

    static var color: Color {
        FieldInk.ink.opacity(0.14)
    }
}
