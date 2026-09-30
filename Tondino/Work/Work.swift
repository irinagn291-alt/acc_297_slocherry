import Foundation

/// Role: Work. One saved panel in the crate. Lodged-ness is this role, not a parallel bool.
enum WorkRole: String, Codable, Sendable, Equatable {
    case loose
    case lodged
}

/// Role: Work. Accession is the Getty duplicate key. Cut samples only Loose rows. SF Pro is the system face.
struct Work: Identifiable, Equatable, Sendable, Codable {
    var id: UUID
    var accession: String
    var objectURI: String
    var maker: String
    var title: String
    var imageID: String?
    var objectHref: String?
    var daykey: Int
    var role: WorkRole

    var thumbURL: URL? {
        CatalogClient.thumbURL(imageID: imageID)
    }

    static func loose(
        from row: CatalogRow,
        id: UUID = UUID(),
        daykey: Int
    ) -> Work {
        Work(
            id: id,
            accession: row.accession,
            objectURI: row.objectURI,
            maker: row.maker,
            title: row.title,
            imageID: row.imageID,
            objectHref: row.objectHref,
            daykey: daykey,
            role: .loose
        )
    }
}

/// Role: Work. Catalog row before it is filed Loose. Cached so empty or failed Getty search still cuts from the shelf.
struct CatalogRow: Identifiable, Equatable, Sendable, Codable {
    var objectURI: String
    var accession: String
    var maker: String
    var title: String
    var imageID: String?
    var objectHref: String?

    var id: String { accession }

    var thumbURL: URL? {
        CatalogClient.thumbURL(imageID: imageID)
    }

    var hasUsableImage: Bool {
        thumbURL != nil
    }
}
