//
//  AuthorDetailView.swift
//  SDP26
//
//  Created by José Luis Corral López on 6/2/26.
//

import SwiftUI
import NetworkAPI

struct AuthorDetailView: View {
    let author: AuthorDTO
    @State private var viewModel = MangasByAuthorViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Author Header
                VStack(spacing: 16) {
                    Text(author.firstName.prefix(1).uppercased() + author.lastName.prefix(1).uppercased())
                        .largeAvatar()

                    VStack(spacing: 4) {
                        Text(author.fullName)
                            .font(.title2)
                            .fontWeight(.bold)

                        Label(author.role.rawValue, systemImage: author.role.icon)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top)

                // Mangas Section
                VStack(alignment: .leading, spacing: 12) {
                    if viewModel.isLoading && viewModel.mangas.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        ForEach(viewModel.mangas) { manga in
                            NavigationLink(value: manga) {
                                AuthorMangaRow(
                                    manga: manga,
                                    role: viewModel.findAuthorRole(in: manga)
                                )
                            }
                            .buttonStyle(.plain)

                            if manga.id != viewModel.mangas.last?.id {
                                Divider()
                            }
                        }

                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                }
                .sectionHeader("Mangas")
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: MangaDTO.self) { manga in
            MangaDetailView(manga: manga)
        }
        .task {
            await viewModel.fetchMangasByAuthor(author: author)

            // Preload images in parallel
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

struct AuthorMangaRow: View {
    let manga: MangaDTO
    let role: AuthorRole

    var body: some View {
        HStack(spacing: 12) {
            CachedAsyncImage(url: manga.imageURL, width: 60, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(manga.title)
                    .rowTitle()

                Label(role.rawValue, systemImage: role.icon)
                    .secondaryText()

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text(manga.score.formatted(.number.precision(.fractionLength(2))))
                }
                .secondaryText()
            }

        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        AuthorDetailView(author: AuthorDTO(
            id: UUID(),
            firstName: "Eiichiro",
            lastName: "Oda",
            role: .storyAndArt
        ))
    }
}
