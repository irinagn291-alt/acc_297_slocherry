import Foundation

/// Role: Work. Typed transport failures. DTO decode never crashes the field.
enum CatalogFault: Error, Equatable, Sendable {
    case cancelled
    case missing
    case transport
    case malformed
}

/// Role: Work. One HTTP hop. Injected so tests never leave the process.
protocol CatalogHopping: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

/// Role: Work. URLSession hop, 15 s timeout, app User-Agent on every request.
struct CatalogSessionHop: CatalogHopping {
    let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = CatalogClient.timeout
        configuration.timeoutIntervalForResource = CatalogClient.timeout
        configuration.httpAdditionalHeaders = ["User-Agent": CatalogClient.userAgent]
        self.session = URLSession(configuration: configuration)
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
}

struct SparqlBundleDTO: Decodable, Sendable {
    var results: SparqlResultsDTO?
}

struct SparqlResultsDTO: Decodable, Sendable {
    var bindings: [SparqlBindingDTO]?
}

struct SparqlBindingDTO: Decodable, Sendable {
    var object: SparqlTermDTO?
    var obj: SparqlTermDTO?

    var uri: String? {
        object?.value ?? obj?.value
    }
}

struct SparqlTermDTO: Decodable, Sendable {
    var type: String?
    var value: String?
}

struct GettyObjectDTO: Decodable, Sendable {
    var id: String?
    var type: String?
    var label: String?
    var identifiedBy: [GettyIdentifiedDTO]?
    var producedBy: GettyProductionDTO?
    var representation: [GettyRepresentationDTO]?

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case label = "_label"
        case identifiedBy = "identified_by"
        case producedBy = "produced_by"
        case representation
    }

    func asRow() -> CatalogRow? {
        let objectURI = (id ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !objectURI.isEmpty else { return nil }
        let accession = Self.accession(from: identifiedBy) ?? ""
        guard !accession.isEmpty else { return nil }
        let maker = Self.maker(from: producedBy)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !maker.isEmpty else { return nil }
        let rawTitle = (label ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let named = Self.preferredTitle(from: identifiedBy)
        var title = named ?? rawTitle
        if title.hasSuffix(" (\(accession))") {
            title = String(title.dropLast(accession.count + 3)).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if title.isEmpty { title = rawTitle }
        guard !title.isEmpty else { return nil }
        let imageID = Self.imageID(from: representation)
        return CatalogRow(
            objectURI: objectURI,
            accession: accession,
            maker: maker,
            title: title,
            imageID: imageID,
            objectHref: objectURI
        )
    }

    private static func accession(from items: [GettyIdentifiedDTO]?) -> String? {
        guard let items else { return nil }
        for item in items where item.type == "Identifier" {
            let marks = item.classifierMarks
            if marks.contains("accession") {
                let content = (item.content ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                if !content.isEmpty { return content }
            }
        }
        return nil
    }

    private static func preferredTitle(from items: [GettyIdentifiedDTO]?) -> String? {
        guard let items else { return nil }
        var fallback: String?
        for item in items where item.type == "Name" {
            let content = (item.content ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !content.isEmpty else { continue }
            let marks = item.classifierMarks
            if marks.contains("preferred") || marks.contains("primary") {
                return content
            }
            if fallback == nil { fallback = content }
        }
        return fallback
    }

    private static func maker(from production: GettyProductionDTO?) -> String? {
        guard let production else { return nil }
        if let label = production.carriedOutBy?.firstLabel { return label }
        for part in production.part ?? [] {
            if let label = part.carriedOutBy?.firstLabel { return label }
        }
        return nil
    }

    private static func imageID(from representations: [GettyRepresentationDTO]?) -> String? {
        guard let representations else { return nil }
        for item in representations {
            if let id = CatalogClient.iiifImageID(from: item.id) {
                return id
            }
        }
        return nil
    }
}

struct GettyIdentifiedDTO: Decodable, Sendable {
    var type: String?
    var content: String?
    var label: String?
    var classifiedAs: [GettyTypeDTO]?

    enum CodingKeys: String, CodingKey {
        case type
        case content
        case label = "_label"
        case classifiedAs = "classified_as"
    }

    var classifierMarks: String {
        let fromTypes = (classifiedAs ?? []).compactMap(\.label).joined(separator: " ")
        return (fromTypes + " " + (label ?? "")).lowercased()
    }
}

struct GettyTypeDTO: Decodable, Sendable {
    var id: String?
    var type: String?
    var label: String?

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case label = "_label"
    }
}

struct GettyProductionDTO: Decodable, Sendable {
    var type: String?
    var label: String?
    var carriedOutBy: GettyAgentListDTO?
    var part: [GettyProductionDTO]?

    enum CodingKeys: String, CodingKey {
        case type
        case label = "_label"
        case carriedOutBy = "carried_out_by"
        case part
    }
}

struct GettyAgentDTO: Decodable, Sendable {
    var id: String?
    var type: String?
    var label: String?

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case label = "_label"
    }
}

struct GettyAgentListDTO: Decodable, Sendable {
    var agents: [GettyAgentDTO]

    var firstLabel: String? {
        agents
            .map { ($0.label ?? "").trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
    }

    init(from decoder: Decoder) throws {
        if let array = try? decoder.singleValueContainer().decode([GettyAgentDTO].self) {
            agents = array
            return
        }
        agents = [try GettyAgentDTO(from: decoder)]
    }
}

struct GettyRepresentationDTO: Decodable, Sendable {
    var id: String?
    var type: String?
    var label: String?

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case label = "_label"
    }
}

/// Role: Work. Owns Getty SPARQL search. cgi search pl maps to query, format=json, LIMIT page_size, OFFSET (page-1)*page_size, then hydrates each object URI. Never Open Food Facts.
actor CatalogClient {
    static let userAgent = "Tondino/1.0 (iOS; +https://tondino-field.pro)"
    static let timeout: TimeInterval = 15
    static let searchHost = "data.getty.edu"
    static let searchPath = "/museum/collection/sparql"
    static let objectPathPrefix = "/museum/collection/object"
    static let mediaHost = "media.getty.edu"
    /// Programmer constant; the domain string is fixed in SPEC.md.
    static let contactURL = URL(string: "https://tondino-field.pro/contact-us")!
    /// Programmer constant; Getty credit lives on Settings.
    static let gettyHomeURL = URL(string: "https://www.getty.edu")!
    static let gettyOpenContentURL = URL(string: "https://www.getty.edu/projects/open-content-program/")!
    static let searchURL = URL(string: "https://data.getty.edu/museum/collection/sparql")!

    private let hop: any CatalogHopping
    private let decoder: JSONDecoder

    init(hop: any CatalogHopping) {
        self.hop = hop
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        self.decoder = decoder
    }

    init() {
        self.init(hop: CatalogSessionHop())
    }

    func search(query: String, page: Int = 1, pageSize: Int = 8) async throws -> [CatalogRow] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        let request = Self.searchRequest(query: trimmed, page: page, pageSize: pageSize)
        let data = try await send(request)
        let bundle: SparqlBundleDTO
        do {
            bundle = try decoder.decode(SparqlBundleDTO.self, from: data)
        } catch is CancellationError {
            throw CatalogFault.cancelled
        } catch {
            throw CatalogFault.malformed
        }
        let uris = (bundle.results?.bindings ?? []).compactMap(\.uri)
        var rows: [CatalogRow] = []
        var seen = Set<String>()
        rows.reserveCapacity(uris.count)
        for uri in uris {
            try Task.checkCancellation()
            guard let objectID = Self.objectID(from: uri) else { continue }
            guard let row = try await hydrate(objectID: objectID) else { continue }
            if seen.insert(row.accession).inserted {
                rows.append(row)
            }
        }
        let preferred = rows.filter(\.hasUsableImage)
        return preferred.isEmpty ? rows : preferred
    }

    nonisolated static func searchRequest(query: String, page: Int = 1, pageSize: Int = 8) -> URLRequest {
        let pageIndex = max(page, 1)
        let size = min(max(pageSize, 1), 40)
        let offset = (pageIndex - 1) * size
        let sparql = sparqlQuery(matching: query, limit: size, offset: offset)
        var parts = URLComponents()
        parts.scheme = "https"
        parts.host = searchHost
        parts.path = searchPath
        parts.queryItems = [
            URLQueryItem(name: "query", value: sparql),
            URLQueryItem(name: "format", value: "json"),
        ]
        var request = URLRequest(url: parts.url ?? searchURL, timeoutInterval: timeout)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/sparql-results+json", forHTTPHeaderField: "Accept")
        return request
    }

    nonisolated static func objectRequest(objectID: String) -> URLRequest {
        var parts = URLComponents()
        parts.scheme = "https"
        parts.host = searchHost
        parts.path = "\(objectPathPrefix)/\(objectID)"
        let fallback = URL(string: "https://data.getty.edu\(objectPathPrefix)/\(objectID)") ?? searchURL
        var request = URLRequest(url: parts.url ?? fallback, timeoutInterval: timeout)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/ld+json", forHTTPHeaderField: "Accept")
        return request
    }

    nonisolated static func thumbURL(imageID: String?) -> URL? {
        guard let imageID, !imageID.isEmpty else { return nil }
        var parts = URLComponents()
        parts.scheme = "https"
        parts.host = mediaHost
        parts.path = "/iiif/image/\(imageID)/full/843,/0/default.jpg"
        return parts.url
    }

    nonisolated static func iiifImageID(from href: String?) -> String? {
        guard let href, !href.isEmpty else { return nil }
        let marker = "/iiif/image/"
        guard let range = href.range(of: marker) else { return nil }
        let rest = href[range.upperBound...]
        let token = rest.split(separator: "/").first.map(String.init) ?? ""
        return token.isEmpty ? nil : token
    }

    nonisolated static func objectID(from uri: String) -> String? {
        let trimmed = uri.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        guard let url = URL(string: trimmed) else { return nil }
        let last = url.lastPathComponent.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return last.isEmpty ? nil : last
    }

    nonisolated static func sparqlQuery(matching query: String, limit: Int, offset: Int) -> String {
        let needle = escape(query)
        return """
        PREFIX crm: <http://www.cidoc-crm.org/cidoc-crm/>
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
        SELECT DISTINCT ?object WHERE {
          ?object a crm:E22_Human-Made_Object .
          ?object rdfs:label ?label .
          FILTER(CONTAINS(LCASE(STR(?label)), LCASE("\(needle)")))
        }
        LIMIT \(limit) OFFSET \(offset)
        """
    }

    private func hydrate(objectID: String) async throws -> CatalogRow? {
        let request = Self.objectRequest(objectID: objectID)
        do {
            let data = try await send(request)
            let dto: GettyObjectDTO
            do {
                dto = try decoder.decode(GettyObjectDTO.self, from: data)
            } catch is CancellationError {
                throw CatalogFault.cancelled
            } catch {
                return nil
            }
            return dto.asRow()
        } catch CatalogFault.missing {
            return nil
        }
    }

    private func send(_ request: URLRequest, retry: Bool = true) async throws -> Data {
        do {
            try Task.checkCancellation()
            let (data, response) = try await hop.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw CatalogFault.transport
            }
            if http.statusCode == 404 {
                throw CatalogFault.missing
            }
            guard (200 ..< 300).contains(http.statusCode) else {
                if retry, http.statusCode >= 500 {
                    return try await send(request, retry: false)
                }
                throw CatalogFault.transport
            }
            return data
        } catch is CancellationError {
            throw CatalogFault.cancelled
        } catch let urlError as URLError where urlError.code == .cancelled {
            throw CatalogFault.cancelled
        } catch let fault as CatalogFault {
            throw fault
        } catch {
            if retry, Self.transient(error) {
                return try await send(request, retry: false)
            }
            throw CatalogFault.transport
        }
    }

    private static func transient(_ error: Error) -> Bool {
        guard let urlError = error as? URLError else { return false }
        switch urlError.code {
        case .timedOut, .networkConnectionLost, .notConnectedToInternet,
             .cannotConnectToHost, .cannotFindHost, .dnsLookupFailed:
            return true
        default:
            return false
        }
    }

    private static func escape(_ raw: String) -> String {
        raw
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\r", with: " ")
    }
}
