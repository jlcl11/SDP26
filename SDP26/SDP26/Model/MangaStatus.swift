//
//  MangaStatus.swift
//  SDP26
//
//  Created by José Luis Corral López on 28/1/26.
//

import Foundation

enum MangaStatus: String, Codable, Sendable {
    case ongoing = "ongoing"
    case completed = "completed"
    case onHiatus = "on_hiatus"
    case cancelled = "cancelled"
    case currentlyReading = "currently_reading"
    case currentlyPublishing = "currently_publishing"
    case owned = "owned"
    case publishing = "publishing"
    case finished = "finished"
    case none = "none"

    var displayName: String {
        switch self {
        case .ongoing: "Ongoing"
        case .completed: "Completed"
        case .onHiatus: "On Hiatus"
        case .cancelled: "Cancelled"
        case .currentlyReading: "Currently Reading"
        case .currentlyPublishing: "Currently Publishing"
        case .owned: "Owned"
        case .publishing: "Publishing"
        case .finished: "Finished"
        case .none: "—"
        }
    }
}
