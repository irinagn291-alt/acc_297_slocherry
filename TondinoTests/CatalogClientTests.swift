import XCTest
@testable import Tondino

final class CatalogClientTests: XCTestCase {
    func testCgiSearchPlMapsOntoGettySparqlQueryFormatJsonLimitOffset() throws {
        let request = CatalogClient.searchRequest(query: "irises", page: 2, pageSize: 3)
        let url = try XCTUnwrap(request.url)
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        let keyed = Dictionary(uniqueKeysWithValues: items.compactMap { item in
            item.value.map { (item.name, $0) }
        })
        XCTAssertEqual(url.host, "data.getty.edu")
        XCTAssertEqual(url.path, "/museum/collection/sparql")
        XCTAssertEqual(keyed["format"], "json")
        let sparql = try XCTUnwrap(keyed["query"])
        XCTAssertTrue(sparql.contains("LIMIT 3"))
        XCTAssertTrue(sparql.contains("OFFSET 3"))
        XCTAssertTrue(sparql.lowercased().contains("irises"))
        XCTAssertNil(keyed["search_terms"])
        XCTAssertNil(keyed["page"])
        XCTAssertNil(keyed["page_size"])
        XCTAssertFalse(url.absoluteString.contains("openfoodfacts"))
        XCTAssertFalse(url.absoluteString.contains("cgi/search.pl"))
        XCTAssertFalse(url.absoluteString.contains("api.artic.edu"))
        XCTAssertFalse(url.absoluteString.contains("collectionapi.metmuseum.org"))
        XCTAssertFalse(url.absoluteString.contains("api.nga.gov"))
        XCTAssertEqual(request.value(forHTTPHeaderField: "User-Agent"), CatalogClient.userAgent)
        XCTAssertEqual(request.timeoutInterval, 15)

        let object = CatalogClient.objectRequest(objectID: "c88b3df0-de91-4f5b-a9ef-7b2b9a6d8abb")
        let objectURL = try XCTUnwrap(object.url)
        XCTAssertEqual(objectURL.host, "data.getty.edu")
        XCTAssertEqual(objectURL.path, "/museum/collection/object/c88b3df0-de91-4f5b-a9ef-7b2b9a6d8abb")
        XCTAssertEqual(object.value(forHTTPHeaderField: "User-Agent"), CatalogClient.userAgent)
    }

    func testDTOMapsLinkedArtThenDomainRow() async throws {
        let carrier = ScriptedHop(results: [
            .success((GettyFixtures.sparqlJSON, GettyFixtures.response(GettyFixtures.searchURL, 200))),
            .success((GettyFixtures.irisesJSON, GettyFixtures.response(GettyFixtures.objectURL("c88b3df0-de91-4f5b-a9ef-7b2b9a6d8abb"), 200))),
        ])
        let client = CatalogClient(hop: carrier)
        let rows = try await client.search(query: "irises", page: 1, pageSize: 8)
        let row = try XCTUnwrap(rows.first)
        XCTAssertEqual(row.accession, "90.PA.20")
        XCTAssertEqual(row.maker, "Vincent van Gogh")
        XCTAssertEqual(row.title, "Irises")
        XCTAssertEqual(row.imageID, "8c255d80-7382-46db-9fa8-892c0d37247e")
        XCTAssertEqual(
            row.thumbURL,
            URL(string: "https://media.getty.edu/iiif/image/8c255d80-7382-46db-9fa8-892c0d37247e/full/843,/0/default.jpg")
        )
        let request = await carrier.recordedRequests().first
        XCTAssertEqual(request?.value(forHTTPHeaderField: "User-Agent"), CatalogClient.userAgent)
        XCTAssertEqual(rows.count, 1)
    }

    func testPageAndPageSizeBecomeLimitOffset() async throws {
        let carrier = ScriptedHop(results: [
            .success((GettyFixtures.sparqlPageJSON, GettyFixtures.response(GettyFixtures.searchURL, 200))),
            .success((GettyFixtures.halberdierJSON, GettyFixtures.response(GettyFixtures.objectURL("56016db9-20a4-4a99-814b-23ac542a106e"), 200))),
        ])
        let client = CatalogClient(hop: carrier)
        let rows = try await client.search(query: "halberdier", page: 2, pageSize: 1)
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows.first?.accession, "89.PA.49")
        let requests = await carrier.recordedRequests()
        XCTAssertEqual(requests.count, 2)
        let sparql = try XCTUnwrap(requests[0].url.flatMap {
            URLComponents(url: $0, resolvingAgainstBaseURL: false)?.queryItems?.first { $0.name == "query" }?.value
        })
        XCTAssertTrue(sparql.contains("LIMIT 1"))
        XCTAssertTrue(sparql.contains("OFFSET 1"))
        XCTAssertEqual(requests[1].url?.path, "/museum/collection/object/56016db9-20a4-4a99-814b-23ac542a106e")
    }

    func testPrefersNonEmptyIIIFRepresentation() async throws {
        let carrier = ScriptedHop(results: [
            .success((GettyFixtures.twoURIJSON, GettyFixtures.response(GettyFixtures.searchURL, 200))),
            .success((GettyFixtures.noImageJSON, GettyFixtures.response(GettyFixtures.objectURL("no-image"), 200))),
            .success((GettyFixtures.irisesJSON, GettyFixtures.response(GettyFixtures.objectURL("c88b3df0-de91-4f5b-a9ef-7b2b9a6d8abb"), 200))),
        ])
        let client = CatalogClient(hop: carrier)
        let rows = try await client.search(query: "gogh")
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows.first?.accession, "90.PA.20")
        XCTAssertNotNil(rows.first?.imageID)
    }

    func testTransientTransportRetriesOnce() async throws {
        let carrier = ScriptedHop(results: [
            .failure(URLError(.timedOut)),
            .success((GettyFixtures.sparqlJSON, GettyFixtures.response(GettyFixtures.searchURL, 200))),
            .success((GettyFixtures.irisesJSON, GettyFixtures.response(GettyFixtures.objectURL("c88b3df0-de91-4f5b-a9ef-7b2b9a6d8abb"), 200))),
        ])
        let client = CatalogClient(hop: carrier)
        let rows = try await client.search(query: "irises")
        XCTAssertEqual(rows.count, 1)
        let count = await carrier.recordedRequests().count
        XCTAssertEqual(count, 3)
    }

    func testDoesNotRetry404() async {
        let carrier = ScriptedHop(results: [
            .success((Data(), GettyFixtures.response(GettyFixtures.searchURL, 404))),
            .success((GettyFixtures.sparqlJSON, GettyFixtures.response(GettyFixtures.searchURL, 200))),
        ])
        let client = CatalogClient(hop: carrier)
        do {
            _ = try await client.search(query: "irises")
            XCTFail("expected missing")
        } catch {
            XCTAssertEqual(error as? CatalogFault, .missing)
        }
        let count = await carrier.recordedRequests().count
        XCTAssertEqual(count, 1)
    }

    func testMalformedJSONIsHandled() async {
        let carrier = ScriptedHop(results: [
            .success((Data("not-json".utf8), GettyFixtures.response(GettyFixtures.searchURL, 200))),
        ])
        let client = CatalogClient(hop: carrier)
        do {
            _ = try await client.search(query: "irises")
            XCTFail("malformed")
        } catch {
            XCTAssertEqual(error as? CatalogFault, .malformed)
        }
    }

    func testEmptyQueryDoesNotHitNetwork() async throws {
        let carrier = ScriptedHop(results: [
            .success((GettyFixtures.sparqlJSON, GettyFixtures.response(GettyFixtures.searchURL, 200))),
        ])
        let client = CatalogClient(hop: carrier)
        let rows = try await client.search(query: "   ")
        XCTAssertTrue(rows.isEmpty)
        let count = await carrier.recordedRequests().count
        XCTAssertEqual(count, 0)
    }

    func testMakerFromProducedByPart() throws {
        let dto = try JSONDecoder().decode(GettyObjectDTO.self, from: GettyFixtures.partMakerJSON)
        let row = try XCTUnwrap(dto.asRow())
        XCTAssertEqual(row.maker, "Nested Maker")
        XCTAssertEqual(row.accession, "11.AA.1")
        XCTAssertEqual(row.title, "Nested Panel")
    }
}

private actor ScriptedHop: CatalogHopping {
    private var results: [Result<(Data, URLResponse), Error>]
    private var requests: [URLRequest] = []

    init(results: [Result<(Data, URLResponse), Error>]) {
        self.results = results
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        requests.append(request)
        guard !results.isEmpty else { throw URLError(.cannotConnectToHost) }
        return try results.removeFirst().get()
    }

    func recordedRequests() -> [URLRequest] {
        requests
    }
}

enum GettyFixtures {
    static let searchURL = URL(string: "https://data.getty.edu/museum/collection/sparql")!

    static func objectURL(_ id: String) -> URL {
        URL(string: "https://data.getty.edu/museum/collection/object/\(id)")!
    }

    static let sparqlJSON = Data(
        """
        {"head":{"vars":["object"]},"results":{"bindings":[{"object":{"type":"uri","value":"https://data.getty.edu/museum/collection/object/c88b3df0-de91-4f5b-a9ef-7b2b9a6d8abb"}}]}}
        """.utf8
    )

    static let sparqlPageJSON = Data(
        """
        {"head":{"vars":["object"]},"results":{"bindings":[{"object":{"type":"uri","value":"https://data.getty.edu/museum/collection/object/56016db9-20a4-4a99-814b-23ac542a106e"}}]}}
        """.utf8
    )

    static let twoURIJSON = Data(
        """
        {"head":{"vars":["object"]},"results":{"bindings":[{"object":{"type":"uri","value":"https://data.getty.edu/museum/collection/object/no-image"}},{"object":{"type":"uri","value":"https://data.getty.edu/museum/collection/object/c88b3df0-de91-4f5b-a9ef-7b2b9a6d8abb"}}]}}
        """.utf8
    )

    static let irisesJSON = Data(
        """
        {"id":"https://data.getty.edu/museum/collection/object/c88b3df0-de91-4f5b-a9ef-7b2b9a6d8abb","type":"HumanMadeObject","_label":"Irises (90.PA.20)","identified_by":[{"type":"Identifier","content":"90.PA.20","_label":"Accession Number","classified_as":[{"id":"http://vocab.getty.edu/aat/300312355","type":"Type","_label":"Accession Number"}]},{"type":"Name","content":"Irises","_label":"Preferred Title","classified_as":[{"_label":"Preferred Term"}]}],"produced_by":{"type":"Production","carried_out_by":[{"id":"https://data.getty.edu/museum/collection/person/c3a876a9-5333-40d5-8488-6cc722058f5e","type":"Person","_label":"Vincent van Gogh"}]},"representation":[{"id":"https://media.getty.edu/iiif/image/8c255d80-7382-46db-9fa8-892c0d37247e/full/full/0/default.jpg","type":"VisualItem","_label":"Main View"}]}
        """.utf8
    )

    static let halberdierJSON = Data(
        """
        {"id":"https://data.getty.edu/museum/collection/object/56016db9-20a4-4a99-814b-23ac542a106e","type":"HumanMadeObject","_label":"Portrait of a Halberdier (89.PA.49)","identified_by":[{"type":"Identifier","content":"89.PA.49","_label":"Accession Number","classified_as":[{"_label":"Accession Number"}]},{"type":"Name","content":"Portrait of a Halberdier","classified_as":[{"_label":"Preferred Term"}]}],"produced_by":{"type":"Production","carried_out_by":[{"type":"Person","_label":"Pontormo (Jacopo Carucci)"}]},"representation":[{"id":"https://media.getty.edu/iiif/image/9e96cce9-7a79-4260-b657-bf92ab9a661f/full/full/0/default.jpg","type":"VisualItem"}]}
        """.utf8
    )

    static let noImageJSON = Data(
        """
        {"id":"https://data.getty.edu/museum/collection/object/no-image","type":"HumanMadeObject","_label":"Closed Panel (x.1)","identified_by":[{"type":"Identifier","content":"x.1","classified_as":[{"_label":"Accession Number"}]},{"type":"Name","content":"Closed Panel"}],"produced_by":{"carried_out_by":{"type":"Person","_label":"Restricted Studio"}},"representation":[]}
        """.utf8
    )

    static let partMakerJSON = Data(
        """
        {"id":"https://data.getty.edu/museum/collection/object/part-one","type":"HumanMadeObject","_label":"Nested Panel (11.AA.1)","identified_by":[{"type":"Identifier","content":"11.AA.1","classified_as":[{"_label":"Accession Number"}]},{"type":"Name","content":"Nested Panel"}],"produced_by":{"type":"Production","part":[{"type":"Production","carried_out_by":[{"type":"Person","_label":"Nested Maker"}]}]},"representation":[{"id":"https://media.getty.edu/iiif/image/aaaa/full/full/0/default.jpg"}]}
        """.utf8
    )

    static func response(_ url: URL, _ code: Int) -> URLResponse {
        HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: ["Content-Type": "application/json"])!
    }
}
