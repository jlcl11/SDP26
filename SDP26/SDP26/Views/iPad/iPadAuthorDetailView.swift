//
//  iPadAuthorDetailView.swift
//  SDP26
//
//  Created by José Luis Corral López on 6/2/26.
//

import SwiftUI
import NetworkAPI

struct iPadAuthorDetailView: View {
    let author: AuthorDTO
    @State private var viewModel = MangasByAuthorViewModel()
    @State private var selectedManga: MangaDTO?

    private let columns = [
        GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 20)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Author Header
                HStack(spacing: 24) {
                    Text(author.firstName.prefix(1).uppercased() + author.lastName.prefix(1).uppercased())
                        .extraLargeAvatar()

                    VStack(alignment: .leading, spacing: 8) {
                        Text(author.fullName)
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Label(author.role.rawValue, systemImage: author.role.icon)
                            .font(.title3)
                            .foregroundStyle(.secondary)

                        if !viewModel.mangas.isEmpty {
                            Text("\(viewModel.mangas.count) works")
                                .font(.subheadline)
                                .foregroundStyle(.tertiary)
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 32)
                .padding(.top, 24)

                Divider()
                    .padding(.horizontal, 32)

                // Mangas Grid
                VStack(alignment: .leading, spacing: 16) {
                    Text("Works")
                        .iPadSectionTitle()
                        .padding(.horizontal, 32)

                    if viewModel.isLoading && viewModel.mangas.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(60)
                    } else if viewModel.mangas.isEmpty {
                        ContentUnavailableView(
                            "No works found",
                            systemImage: "book.closed",
                            description: Text("This author has no registered works")
                        )
                        .padding(60)
                    } else {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(viewModel.mangas) { manga in
                                Button {
                                    selectedManga = manga
                                } label: {
                                    iPadAuthorMangaCard(
                                        manga: manga,
                                        role: viewModel.findAuthorRole(in: manga)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 32)

                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                }
            }
            .padding(.bottom, 32)
        }
        .navigationTitle(author.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedManga) { manga in
            iPadMangaDetailView(manga: manga)
        }
        .task {
            await viewModel.fetchMangasByAuthor(author: author)

            // Preload images
            await withTaskGroup(of: Void.self) { group in
                for manga in viewModel.mangas {
                    if let imageURL = manga.imageURL {
                        group.addTask {
                            _ = await ImageDownloader.shared.loadImage(url: imageURL)
                        }
                    }
                }
            }
        }
    }
}

struct iPadAuthorMangaCard: View {
    let manga: MangaDTO
    let role: AuthorRole

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            CachedAsyncImage(url: manga.imageURL, width: 160, height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .cardShadow()

            VStack(alignment: .leading, spacing: 4) {
                Text(manga.title)
                    .iPadCardTitle()

                Label(role.rawValue, systemImage: role.icon)
                    .secondaryText()

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text(manga.score.formatted(.number.precision(.fractionLength(1))))
                }
                .secondaryText()
            }
        }
        .frame(width: 160)
    }
}

#Preview {
    NavigationStack {
        iPadAuthorDetailView(author: AuthorDTO(
            id: UUID(),
            firstName: "Eiichiro",
            lastName: "Oda",
            role: .storyAndArt
        ))
    }
}
