//
//  AIProfileAnalysisView.swift
//  SDP26
//
//  Created by José Luis Corral López on 9/2/26.
//

import SwiftUI
import FoundationModels

struct AIProfileAnalysisView: View {
    @State private var profile: UserMangaProfile?
    @State private var partialProfile: UserMangaProfile.PartiallyGenerated?
    @State private var isGenerating = false
    @State private var error: String?
    @State private var modelAvailable = true

    private let collectionVM = CollectionVM.shared

    var body: some View {
        List {
            Section {
                headerSection
            }

            if !modelAvailable {
                unavailableSection
            } else if let error {
                errorSection(error)
            } else if isGenerating {
                generatingSection
            } else if let profile {
                profileSection(profile)
            } else if let partial = partialProfile {
                partialProfileSection(partial)
            } else {
                emptySection
            }
        }
        .navigationTitle("AI Profile")
        .task {
            checkModelAvailability()
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "apple.intelligence")
                    .font(.largeTitle)
                    .foregroundStyle(.purple.gradient)

                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Reader Profile")
                        .font(.headline)
                    Text("Powered by Apple Intelligence")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text("Analyze your manga collection to discover your unique reader personality.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if collectionVM.collection.isEmpty {
                Label("Add mangas to your collection first", systemImage: "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundStyle(.orange)
            } else {
                Button {
                    Task {
                        await generateProfile()
                    }
                } label: {
                    HStack {
                        if isGenerating {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "sparkles")
                        }
                        Text(isGenerating ? "Analyzing..." : "Analyze My Collection")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                .disabled(isGenerating || collectionVM.collection.isEmpty || !modelAvailable)
            }
        }
        .padding(.vertical, 8)
    }

    private var unavailableSection: some View {
        Section {
            VStack(spacing: 12) {
                Image(systemName: "apple.intelligence")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text("Apple Intelligence Unavailable")
                    .font(.headline)
                Text("This feature requires a device with Apple Intelligence enabled.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
    }

    private func errorSection(_ error: String) -> some View {
        Section {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundStyle(.orange)
                Text("Analysis Failed")
                    .font(.headline)
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button("Try Again") {
                    self.error = nil
                    Task {
                        await generateProfile()
                    }
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
    }

    private var generatingSection: some View {
        Section("Generating Profile...") {
            if let partial = partialProfile {
                partialProfileContent(partial)
            } else {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Analyzing your collection...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 20)
            }
        }
    }

    private func profileSection(_ profile: UserMangaProfile) -> some View {
        Group {
            Section("Your Reader Type") {
                VStack(alignment: .leading, spacing: 8) {
                    Text(profile.readerType)
                        .font(.title2.bold())
                        .foregroundStyle(.purple)
                    Text(profile.personalityDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section("Personality Traits") {
                ForEach(profile.traits, id: \.self) { trait in
                    Label(trait, systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.primary)
                }
            }

            Section("Reading Pattern") {
                Text(profile.readingPattern)
                    .font(.subheadline)
            }

            Section("Favorite Genre") {
                Label(profile.favoriteGenre, systemImage: "star.fill")
                    .foregroundStyle(.yellow)
            }

            Section("Fun Fact") {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                    Text(profile.funFact)
                        .font(.subheadline)
                }
            }

            Section("Recommendation") {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "book.fill")
                        .foregroundStyle(.blue)
                    Text(profile.recommendation)
                        .font(.subheadline)
                }
            }
        }
    }

    private func partialProfileSection(_ partial: UserMangaProfile.PartiallyGenerated) -> some View {
        Section("Generating...") {
            partialProfileContent(partial)
        }
    }

    private func partialProfileContent(_ partial: UserMangaProfile.PartiallyGenerated) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if let readerType = partial.readerType {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reader Type")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(readerType)
                        .font(.headline)
                        .foregroundStyle(.purple)
                }
            }

            if let personality = partial.personalityDescription {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Personality")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(personality)
                        .font(.subheadline)
                }
            }

            if let traits = partial.traits, !traits.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Traits")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ForEach(traits, id: \.self) { trait in
                        Text("• \(trait)")
                            .font(.subheadline)
                    }
                }
            }

            if let pattern = partial.readingPattern {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reading Pattern")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(pattern)
                        .font(.subheadline)
                }
            }

            if let genre = partial.favoriteGenre {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Favorite Genre")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(genre)
                        .font(.subheadline)
                }
            }

            if let funFact = partial.funFact {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Fun Fact")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(funFact)
                        .font(.subheadline)
                }
            }

            if let recommendation = partial.recommendation {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recommendation")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(recommendation)
                        .font(.subheadline)
                }
            }

            ProgressView()
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 8)
    }

    private var emptySection: some View {
        Section {
            VStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.largeTitle)
                    .foregroundStyle(.purple.opacity(0.5))
                Text("Ready to Analyze")
                    .font(.headline)
                Text("Tap the button above to generate your unique reader profile based on your manga collection.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
    }

    // MARK: - Methods

    private func checkModelAvailability() {
        let model = SystemLanguageModel.default
        switch model.availability {
        case .available:
            modelAvailable = true
        case .unavailable:
            modelAvailable = false
        @unknown default:
            modelAvailable = false
        }
    }

    private func generateProfile() async {
        guard modelAvailable else { return }

        isGenerating = true
        error = nil
        profile = nil
        partialProfile = nil

        do {
            let tool = MangaCollectionTool()

            let session = LanguageModelSession(
                tools: [tool],
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

            for try await snapshot in stream {
                await MainActor.run {
                    partialProfile = snapshot.content
                }
            }

            // Get the final complete result
            let response = try await session.respond(
                to: "Based on the collection analysis, finalize my reader profile.",
                generating: UserMangaProfile.self,
                options: GenerationOptions(temperature: 0.8)
            )

            await MainActor.run {
                profile = response.content
                partialProfile = nil
                isGenerating = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                isGenerating = false
            }
        }
    }
}

#Preview {
    NavigationStack {
        AIProfileAnalysisView()
    }
}
