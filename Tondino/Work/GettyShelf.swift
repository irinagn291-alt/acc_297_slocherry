import Foundation

/// Role: Work. Bundled Getty shelf. Empty or failed Getty search still cuts from here. Not a food catalog.
struct GettyShelf: Sendable {
    var rows: [CatalogRow]

    static let bundled = GettyShelf(rows: Self.makeRows())

    private static func makeRows() -> [CatalogRow] {
        [
            row(
                "c88b3df0-de91-4f5b-a9ef-7b2b9a6d8abb",
                "90.PA.20",
                "Vincent van Gogh",
                "Irises",
                "8c255d80-7382-46db-9fa8-892c0d37247e"
            ),
            row(
                "56016db9-20a4-4a99-814b-23ac542a106e",
                "89.PA.49",
                "Pontormo (Jacopo Carucci)",
                "Portrait of a Halberdier",
                "9e96cce9-7a79-4260-b657-bf92ab9a661f"
            ),
            row(
                "d91348af-37bf-49cd-8322-f7d4f0751cd9",
                "95.PB.7",
                "Rembrandt Harmensz. van Rijn",
                "The Abduction of Europa",
                "9dffc982-738e-434b-8715-0f77be75d28c"
            ),
            row(
                "008a2414-cbba-4455-951d-f8599b9d5ce9",
                "87.PA.96",
                "James Ensor",
                "Christ's Entry into Brussels in 1889",
                "dd1d3304-17dc-43f7-85d9-5e4a6286a980"
            ),
            row(
                "912e77d2-c887-4c1a-8817-7c2dde0fc12b",
                "96.PA.8",
                "Paul Cézanne",
                "Still Life with Apples",
                "f0d223e4-3254-4482-8c65-e5468e186efb"
            ),
            row(
                "f2ff5f5f-80d7-47a5-b745-8807d121b5d3",
                "68.PA.2",
                "Anthony van Dyck",
                "Portrait of Agostino Pallavicini",
                "6f22d350-eb77-4992-b60d-72e49c64d326"
            ),
            row(
                "9a9cebf1-6d57-4153-aeac-3d5aa0ad9b2c",
                "95.PA.63",
                "Claude Monet",
                "Wheatstacks, Snow Effect, Morning",
                "c7a070ce-bae3-4424-8ad3-55e3dea5e1ff"
            ),
            row(
                "977d89bd-db0c-4d86-af76-cd3cf82722ed",
                "2002.51",
                "Georges Seurat",
                "Madame Seurat, the Artist's Mother",
                "3e827c41-a255-4519-b8cf-c52ae9be322d"
            ),
        ]
    }

    private static func row(
        _ objectID: String,
        _ accession: String,
        _ maker: String,
        _ title: String,
        _ imageID: String
    ) -> CatalogRow {
        let uri = "https://data.getty.edu/museum/collection/object/\(objectID)"
        return CatalogRow(
            objectURI: uri,
            accession: accession,
            maker: maker,
            title: title,
            imageID: imageID,
            objectHref: uri
        )
    }
}
