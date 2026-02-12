//
//  AIProfileAnalysisViewModel.swift
//  SDP26
//
//  Created by José Luis Corral López on 9/2/26.
//

import Foundation
import FoundationModels

@Observable @MainActor
final class AIProfileAnalysisViewModel {
    enum State: Equatable {
        case idle
        case generating(UserMangaProfile.PartiallyGenerated?)
        case completed(UserMangaProfile)
        case error(String)
        case unavailable
    }

    private(set) var state: State = .idle

    var isModelAvailable: Bool {
        if case .unavailable = state { return false }
        return true
    }

    var canGenerate: Bool {
        guard isModelAvailable else { return false }
        guard !CollectionVM.shared.collection.isEmpty else { return false }
        if case .generating = state { return false }
        return true
    }

    var isGenerating: Bool {
        if case .generating = state { return true }
        return false
    }

    func checkModelAvailability() {
        let model = SystemLanguageModel.default
        switch model.availability {
        case .available:
            if case .unavailable = state {
                state = .idle
            }
        case .unavailable:
            state = .unavailable
        @unknown default:
            state = .unavailable
        }
    }

    func generateProfile() async {
        guard canGenerate else { return }

        state = .generating(nil)

        do {
            let session = LanguageModelSession(
                tools: [MangaCollectionTool()],
                instructions: {
                    """
                    You are a manga expert and personality analyst. Your task is to analyze the user's manga collection and create a fun, insightful reader profile.

                    Use the getMangaCollection tool to retrieve the user's collection data, then generate a UserMangaProfile based on their preferences.

                    Be creative with the reader type name - make it memorable and fun.
                    The personality description should be insightful but lighthearted.
                    Traits should reflect reading preferences (e.g., "Patient collector", "Genre explorer", "Completionist").
                    The recommendation should be specific and explain why it fits their taste.

                    Keep responses in the same language as the manga titles in the collection when possible.
                    """
                }
            )

            let stream = session.streamResponse(
                generating: UserMangaProfile.self,
                options: GenerationOptions(temperature: 0.8)
            ) {
                "Analyze my manga collection and create my unique reader profile. Use the tool to get my collection data first."
            }

            var lastPartial: UserMangaProfile.PartiallyGenerated?

            for try await snapshot in stream {
                lastPartial = snapshot.content
                state = .generating(snapshot.content)
            }

            // Build final profile from the last partial
            if let partial = lastPartial,
               let readerType = partial.readerType,
               let personalityDescription = partial.personalityDescription,
               let traits = partial.traits,
               let readingPattern = partial.readingPattern,
               let favoriteGenre = partial.favoriteGenre,
               let funFact = partial.funFact,
               let recommendation = partial.recommendation {
                let profile = UserMangaProfile(
                    readerType: readerType,
                    personalityDescription: personalityDescription,
                    traits: traits,
                    readingPattern: readingPattern,
                    favoriteGenre: favoriteGenre,
                    funFact: funFact,
                    recommendation: recommendation
                )
                state = .completed(profile)
            } else {
                state = .error("Failed to generate complete profile")
            }

        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
