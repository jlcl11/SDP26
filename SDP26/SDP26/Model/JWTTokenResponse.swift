//
//  JWTTokenResponse.swift
//  SDP26
//
//  Created by José Luis Corral López on 28/1/26.
//

import Foundation

struct JWTTokenResponse: Codable, Sendable {
    let expiresIn: Int      // 86400 = 24 horas
    let tokenType: String   // "Bearer"
    let token: String
}
