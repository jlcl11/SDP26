//
//  NetworkInteractor.swift
//  EmpleadosAPI
//
//  Created by Julio César Fernández Muñoz on 19/11/25.
//

import Foundation

public protocol NetworkInteractor {}

extension NetworkInteractor {
    public func getJSON<JSON>(_ request: URLRequest, type: JSON.Type) async throws(NetworkError) -> JSON where JSON: Codable {
        let (data, httpResponse) = try await URLSession.shared.getData(for: request)
        if httpResponse.statusCode == 200 {
            do {
                return try JSONDecoder().decode(type, from: data)
            } catch {
                throw NetworkError.json(error)
            }
        } else {
            throw NetworkError.status(httpResponse.statusCode)
        }
    }
    
    public func postJSON(_ request: URLRequest, status: Int = 200) async throws(NetworkError) {
        let (_, httpResponse) = try await URLSession.shared.getData(for: request)
        if httpResponse.statusCode != status {
            throw NetworkError.status(httpResponse.statusCode)
        }
    }
}
