//
//  iPadMangaListView.swift
//  SDP26
//
//  Created by José Luis Corral López on 10/2/26.
//

import SwiftUI

struct iPadMangaListView: View {
    @Bindable var mangaVM = MangaViewModel.shared
    @Bindable var bestMangaVM = BestMangaViewModel.shared
    @State private var selectedManga: MangaDTO?

    private let columns = [
        GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 20)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Best Mangas Section
                if !bestMangaVM.mangas.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Best Mangas", systemImage: "star.fill")
                            .iPadSectionTitle()
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(bestMangaVM.mangas.sorted { $0.score > $1.score }) { manga in
                                    Button {
                                        selectedManga = manga
                                    } label: {
                                        iPadMangaCard(manga: manga)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                Divider()
                    .padding(.horizontal)

                // All Mangas Grid
                VStack(alignment: .leading, spacing: 12) {
                    Label("All Mangas", systemImage: "book.fill")
                        .iPadSectionTitle()
                        .padding(.horizontal)

                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(mangaVM.mangas) { manga in
                            Button {
                                selectedManga = manga
                            } label: {
                                iPadMangaCard(manga: manga)
                            }
                            .buttonStyle(.plain)
                            .onAppear {
                                Task {
                                    await mangaVM.loadNextPageIfNeeded(for: manga)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                if mangaVM.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Mangas")
        .navigationDestination(item: $selectedManga) { manga in
            iPadMangaDetailView(manga: manga)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    mangaVM.showSearchSheet = true
                } label: {
                    Image(systemName: mangaVM.filterIconName)
                }
            }
        }
        .sheet(isPresented: $mangaVM.showSearchSheet) {
            CustomSearchSheet(
                onSearch: { search in
                    Task { await mangaVM.performCustomSearch(search) }
                },
                onReset: {
                    Task { await mangaVM.resetCustomSearch() }
                }
            )
        }
        .task {
            await mangaVM.loadNextPage()
            await bestMangaVM.loadNextPage()
        }
    }
}

struct iPadMangaCard: View {
    let manga: MangaDTO

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            CachedAsyncImage(url: manga.imageURL, width: 160, height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .cardShadow()

            VStack(alignment: .leading, spacing: 4) {
                Text(manga.title)
                    .iPadCardTitle()

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text(manga.score.formatted(.number.precision(.fractionLength(1))))
                }
                .secondaryText()

                Text(manga.status.displayName)
                    .badge(manga.status == .currentlyPublishing ? .green : .blue)
            }
        }
        .frame(width: 160)
    }
}

#Preview {
    NavigationStack {
        iPadMangaListView()
    }
}
