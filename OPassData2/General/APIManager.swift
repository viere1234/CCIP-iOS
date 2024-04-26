//
//  APIManager.swift
//  OPass
//
//  Created by secminhr on 2022/3/4.
//  2024 OPass.
//

import Foundation
import OSLog

private let logger = Logger(subsystem: "OPassData", category: "Fetch")

func fetch<T: Decodable>(from endpoint: String) async throws -> T {
    guard let url = URL(string: endpoint) else {
        logger.error("Invalid URL: \(endpoint)")
        throw LoadError.invalidURL(endpoint)
    }
    let urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
    do {
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        if let response = response as? HTTPURLResponse {
            switch response.statusCode {
            case 403:
                logger.warning("Http 403 Forbidden with url: \(endpoint)")
                throw LoadError.forbidden
            default:
                break
            }
        }
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch LoadError.forbidden {
        throw LoadError.forbidden
    } catch where error is DecodingError {
        logger.error("Decode Faild with: \(error.localizedDescription), url: \(endpoint)")
        throw LoadError.decodeFaild(error)
    } catch {
        logger.error("Fetch Faild with: \(error.localizedDescription), url: \(endpoint)")
        throw LoadError.fetchFaild(error)
    }
}

public enum LoadError: Error, LocalizedError {
    case invalidURL(String)
    case fetchFaild(Error)
    case decodeFaild(Error)
    case missingURL(Feature)
    case incorrectFeature(FeatureType)
    case forbidden

    public var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "Invaild URL with \(url))"
        case .fetchFaild(let error):
            return "Fetch Faild with \(error.localizedDescription)"
        case .decodeFaild(let error):
            return "Decode Faild with \(error.localizedDescription)"
        case .missingURL(let feature):
            return "Missing URL in: \(feature.feature.rawValue)"
        case .incorrectFeature(let feature):
            return "Uncorrect Feature for: \(feature)"
        case .forbidden:
            return "Http 403 Forbidden"
        }
    }
}
