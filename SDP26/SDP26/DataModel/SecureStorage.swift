//
//  SecureStorage.swift
//  SDP26
//
//  Created by José Luis Corral López on 27/1/26.
//

import Foundation

protocol SecureStorage: Sendable {
    func save(key: String, data: Data) async throws
    func load(key: String) async -> Data?
    func delete(key: String) async
}
