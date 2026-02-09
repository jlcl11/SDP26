//
//  MangaListView.swift
//  SDP26
//
//  Created by José Luis Corral López on 3/2/26.
//

import SwiftUI

struct MangaListView: View {
    @Bindable var mangaVM = MangaViewModel.shared
    @Bindable var bestMangaVM = BestMangaViewModel.shared
    private var networkMonitor = NetworkMonitor.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    if !networkMonitor.isConnected {
                        OfflineBanner(message: "No connection - Cannot load mangas")
                    }
                    BestMangasCarousel(mangas: bestMangaVM.mangas.sorted { $0.score > $1.score })

                    ForEach(mangaVM.mangas) { manga in
                        NavigationLink(value: manga) {
                            MangaRow(manga: manga)
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            Task {
                                await mangaVM.loadNextPageIfNeeded(for: manga)
                            }
                        }

                        Divider()
                    }
                    .safeAreaPadding(.horizontal)
                }
            }
            .navigationDestination(for: MangaDTO.self) { manga in
                MangaDetailView(manga: manga)
            }
            .navigationTitle("Mangas")
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
}

#Preview {
    MangaListView()
}
