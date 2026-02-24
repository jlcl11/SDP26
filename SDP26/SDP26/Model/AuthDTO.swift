//
//  AuthDTO.swift
//  SDP26
//
//  Created by José Luis Corral López on 25/1/26.
//

import Foundation

// Use existing JWTTokenResponse from Model folder
typealias AuthResponse = JWTTokenResponse

// Use existing UserCreate from Model folder
typealias UserCredentials = UserCreate

struct EmptyResponse: Codable, Sendable {}
