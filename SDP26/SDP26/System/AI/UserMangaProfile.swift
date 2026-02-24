//
//  UserMangaProfile.swift
//  SDP26
//
//  Created by José Luis Corral López on 21/2/26.
//

import Foundation
import FoundationModels

/// Structured output for the AI-generated user manga profile
@Generable
struct UserMangaProfile: Equatable, Sendable {
    @Guide(description: "A creative name for this type of reader based on their preferences, e.g. 'The Action Enthusiast' or 'The Shonen Veteran'")
    let readerType: String

    @Guide(description: "A brief personality description based on manga preferences (2-3 sentences)")
    let personalityDescription: String

    @Guide(description: "List of 3-4 personality traits inferred from reading habits")
    let traits: [String]

    @Guide(description: "Analysis of reading patterns: whether they complete series, read multiple at once, prefer ongoing or finished series")
    let readingPattern: String

    @Guide(description: "The user's apparent favorite genre based on collection")
    let favoriteGenre: String

    @Guide(description: "A fun fact or observation about their collection")
    let funFact: String

    @Guide(description: "A personalized manga recommendation based on their tastes with explanation")
    let recommendation: String
}
