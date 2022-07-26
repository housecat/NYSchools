//
//  APIError.swift
//  20220726MikhailKouznetsovNYCSchool
//
//  Created by Mikhail Kouznetsov on 7/26/22.
//

import Foundation


enum APIError: Error {
    case noResponse
    case jsonDecodingError(error: DecodingError)
    case decodingErre(error: DecodingError)
    case networkError(error: Error)
    case serverError(error: ServerError)
    case setupError(message: String)
}

extension APIError {
    public var errorDescription: String {
        switch self {
        case .serverError(let error):
            return error.error
        case .setupError(let string):
            return string
        case .jsonDecodingError(let error):
            switch error {
            case .typeMismatch(let key, let value):
                return "error \(key), value \(value) and ERROR: \(error.localizedDescription)"
            case .valueNotFound(let key, let value):
                return "error \(key), value \(value) and ERROR: \(error.localizedDescription)"
            case .keyNotFound(let key, let value):
                return "error \(key), value \(value) and ERROR: \(error.localizedDescription)"
            case .dataCorrupted(let key):
                return "error \(key), and ERROR: \(error.localizedDescription)"
            default:
                return "ERROR: \(error.localizedDescription)"
            }
        default: return self.localizedDescription
        }
    }
    
    public var requestId: String? {
        switch self {
        case .serverError(let error):
            return error.requestId
        default: return nil
        }
    }
}

struct ServerError: Error, Codable {
    var error: String
    var requestId: String?

    enum CodingKeys: String, CodingKey {
        case error = "__error__"
    }
}

