import Foundation

/// Role: Field. Preference keys. Snapshot is JSON Data under tnd.field.v1. Demo is Simulator-only.
enum FieldKey {
    static let snapshot = "tnd.field.v1"
    static let backup = "tnd.field.v1.backup"
    static let demo = "tnd.demo.v1"
}

enum FieldCodecError: Error, Equatable, Sendable {
    case unsupportedSchema(Int)
    case corrupt
}

/// Role: Field. Codable FieldDocument. schemaVersion from 1. Tondo case is stored. Lodged-ness is Work.role.
enum FieldDocument {
    static func encode(_ field: Field) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        var copy = field
        copy.schemaVersion = Field.currentSchema
        return try encoder.encode(RootFile(field: copy))
    }

    static func decode(_ data: Data) throws -> Field {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        let probe: SchemaProbe
        do {
            probe = try decoder.decode(SchemaProbe.self, from: data)
        } catch {
            throw FieldCodecError.corrupt
        }
        switch probe.schemaVersion {
        case 1:
            do {
                var field = try decoder.decode(RootFile.self, from: data).field
                field.schemaVersion = Field.currentSchema
                return field
            } catch let error as FieldCodecError {
                throw error
            } catch {
                throw FieldCodecError.corrupt
            }
        default:
            throw FieldCodecError.unsupportedSchema(probe.schemaVersion)
        }
    }
}

private struct SchemaProbe: Decodable {
    var schemaVersion: Int
}

private struct RootFile: Codable {
    var schemaVersion: Int
    var onboardingComplete: Bool
    var works: [Work]
    var tondo: Tondo
    var lodgeMarks: [LodgeMark]
    var chipMarks: [ChipMark]
    var peelLog: [PeelRef]
    var cachedRows: [CatalogRow]
    var focusedWorkID: UUID?

    init(field: Field) {
        schemaVersion = field.schemaVersion
        onboardingComplete = field.onboardingComplete
        works = field.works
        tondo = field.tondo
        lodgeMarks = field.lodgeMarks
        chipMarks = field.chipMarks
        peelLog = field.peelLog
        cachedRows = field.cachedRows
        focusedWorkID = field.focusedWorkID
    }

    var field: Field {
        Field(
            schemaVersion: schemaVersion,
            onboardingComplete: onboardingComplete,
            works: works,
            tondo: tondo,
            lodgeMarks: lodgeMarks,
            chipMarks: chipMarks,
            peelLog: peelLog,
            cachedRows: cachedRows,
            focusedWorkID: focusedWorkID
        )
    }
}
