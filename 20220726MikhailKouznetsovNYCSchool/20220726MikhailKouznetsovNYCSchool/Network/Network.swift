//
//  Network.swift
//  20220726MikhailKouznetsovNYCSchool
//
//  Created by Mikhail Kouznetsov on 10/27/21.
//

import Foundation
import Combine

enum Endpoint {
    case  schools,
          schoolData
        
    func path() -> String {
        switch self {
        case .schools:
            return "/resource/s3k6-pzi2.json"
        case .schoolData:
            return "/resource/f9bf-2cp4.json"
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case connect = "CONNECT"
    case options = "OPTIONS"
    case trace = "TRACE"
    case patch = "PATCH"
}

struct Network {
    static var idToken: String = "mcnkenhttGm00JI4YIp9bjCwo"

    static var baseURL : URL? {
      return URL(string: "https://data.cityofnewyork.us")
    }
    
    static func get<T: Decodable>(endpoint: Endpoint,
                                  decodingType: T.Type,
                                  httpMethod: HTTPMethod = .get,
                                  useSnakeCase: Bool = true,
                                  dateFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
                                  params: KeyValuePairs<String, String>? = nil,
                                  paramsArray: [[String:String]]? = nil,
                                  body: [String:Any?]? = nil,
                                  queryString: String? = nil) -> AnyPublisher<T?, APIError> {

     guard let url = Network.baseURL?.appendingPathComponent(endpoint.path()),
           var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
     else {
         return Just(nil)
             .setFailureType(to: APIError.self)
             .mapError { _ in APIError.setupError(message: "URL is corrupted")}
             .receive(on: DispatchQueue.main)
             .eraseToAnyPublisher()
     }

     if let params = params {
         var queryItem : [URLQueryItem] = []
         for value in params {
             queryItem.append(URLQueryItem(name: value.key, value: value.value))
         }
         components.queryItems = queryItem
     }

     if let paramsArray = paramsArray {
         var queryItems : [URLQueryItem] = []
         paramsArray.forEach { dict in
             dict.forEach { key, value in
                 queryItems.append(URLQueryItem(name: key, value: value))
             }
         }
         print("QUERY ITEMS: \(queryItems)")
         components.queryItems = queryItems
     }

     if let queryString = queryString {
         components.query = queryString
     }

     var request = URLRequest(url: components.url!)
     request.httpMethod = httpMethod.rawValue

     if let body = body {
         let jsonData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
         request.httpBody = jsonData
     }

     request.addValue(Network.idToken, forHTTPHeaderField: "X-Auth-Token")
     print("URL QUERY", components.url)

     let urlSessionConfig = URLSessionConfiguration.default
     let urlSession = URLSession(configuration: urlSessionConfig)
     
     return urlSession.dataTaskPublisher(for: request)
         .tryMap { data, response in
             let response = response as! HTTPURLResponse
             let status = response.statusCode
             guard 200..<300 ~= status else {
                 let requestId = response.value(forHTTPHeaderField: "x-request-id")
                 if var serverError = try? JSONDecoder().decode(ServerError.self, from: data) {
                     serverError.requestId = requestId
                     print("SERVER ERROR", serverError)
                     throw APIError.serverError(error: serverError)
                 } else {
                     let error = ServerError(error: "Unknown server error", requestId: requestId)
                     throw APIError.serverError(error: error)
                 }
             }
             
             do {
                   let decoder = JSONDecoder()
                   if useSnakeCase {
                       decoder.keyDecodingStrategy = .convertFromSnakeCase
                   }

                   let dateFormatter = DateFormatter()
                   dateFormatter.dateFormat = dateFormat
                   dateFormatter.timeZone = TimeZone(identifier: "UTC")
                   decoder.dateDecodingStrategy = .formatted(dateFormatter)
                   let object = try decoder.decode(T.self, from: data)
                   return object
               }
               catch let error {
                   throw APIError.jsonDecodingError(error: error as! DecodingError)
               }
         }
         .mapError { error in
             if let error = error as? APIError {
                 return error
             } else {
                 return APIError.networkError(error: error)
             }
         }
         .receive(on: DispatchQueue.main)
         .eraseToAnyPublisher()
    }
}
