//
//  AIProfileAnalysisView.swift
//  SDP26
//
//  Created by José Luis Corral López on 9/2/26.
//

import SwiftUI
import FoundationModels

struct AIProfileAnalysisView: View {
    @State private var viewModel = AIProfileAnalysisViewModel()
    private let collectionVM = CollectionVM.shared

    var body: some View {
        List {
            Section {
                headerSection
            }

            contentSection
        }
        .navigationTitle("AI Profile")
        .task {
            viewModel.checkModelAvailability()
        }
    }

    // MARK: - Content Section

    @ViewBuilder
    private var contentSection: some View {
        switch viewModel.state {
        case .unavailable:
            unavailableSection
        case .error(let message):
            errorSection(message)
        case .generating(let partial):
            generatingSection(partial)
        case .completed(let profile):
            profileSection(profile)
        case .idle:
            emptySection
        }
    }

    // MARK: - Header

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
                generateButton
            }
        }
        .padding(.vertical, 8)
    }

    private var generateButton: some View {
        Button {
            Task { await viewModel.generateProfile() }
        } label: {
            HStack {
                if viewModel.isGenerating {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "sparkles")
                }
                Text(viewModel.isGenerating ? "Analyzing..." : "Analyze My Collection")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(.purple)
        .disabled(!viewModel.canGenerate)
    }

    // MARK: - State Sections

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

    private func errorSection(_ message: String) -> some View {
        Section {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundStyle(.orange)
                Text("Analysis Failed")
                    .font(.headline)
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button("Try Again") {
                    Task { await viewModel.generateProfile() }
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
    }

    private func generatingSection(_ partial: UserMangaProfile.PartiallyGenerated?) -> some View {
        Section("Generating Profile...") {
            if let partial {
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

    // MARK: - Profile Display

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

    private func partialProfileContent(_ partial: UserMangaProfile.PartiallyGenerated) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if let readerType = partial.readerType {
                ProfileField(title: "Reader Type", content: readerType, style: .headline)
            }

            if let personality = partial.personalityDescription {
                ProfileField(title: "Personality", content: personality)
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
                ProfileField(title: "Reading Pattern", content: pattern)
            }

            if let genre = partial.favoriteGenre {
                ProfileField(title: "Favorite Genre", content: genre)
            }

            if let funFact = partial.funFact {
                ProfileField(title: "Fun Fact", content: funFact)
            }

            if let recommendation = partial.recommendation {
                ProfileField(title: "Recommendation", content: recommendation)
            }

            ProgressView()
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Helper Views

private struct ProfileField: View {
    let title: String
    let content: String
    var style: Style = .regular

    enum Style {
        case regular
        case headline
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(content)
                .font(style == .headline ? .headline : .subheadline)
                .foregroundStyle(style == .headline ? .purple : .primary)
        }
    }
}

#Preview {
    NavigationStack {
        AIProfileAnalysisView()
    }
}
