//
//  iPadSearchView.swift
//  SDP26
//
//  Created by José Luis Corral López on 6/2/26.
//

import SwiftUI

struct iPadSearchView: View {
    @Bindable var vm = MangaBeginsWithViewModel.shared
    @State private var searchText = ""
    @State private var selectedManga: MangaDTO?

    private let columns = [
        GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 20)
    ]

    var body: some View {
        Group {
            if searchText.isEmpty {
                VStack(spacing: 24) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)

                    Text("Search Mangas")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Type a manga name to start searching")
                        .subtitleStyle()

                    // Recent Searches (placeholder)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Popular Searches")
                            .sectionTitle()
                            .padding(.horizontal)

                        HStack(spacing: 12) {
                            ForEach(["One Piece", "Naruto", "Dragon Ball", "Attack on Titan"], id: \.self) { term in
                                Button {
                                    searchText = term
                                } label: {
                                    Text(term)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(.regularMaterial, in: Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.top, 32)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if vm.isLoading && vm.mangas.isEmpty {
                ProgressView("Searching...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if vm.mangas.isEmpty {
                ContentUnavailableView(
                    "No results",
                    systemImage: "magnifyingglass",
                    description: Text("No mangas found matching \"\(searchText)\"")
                )
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("\(vm.mangas.count) results for \"\(searchText)\"")
                            .subtitleStyle()
                            .padding(.horizontal)

                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(vm.mangas) { manga in
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
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Search")
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search manga by name..."
        )
        .onChange(of: searchText) { _, newValue in
            if newValue.count >= 2 {
                Task { await vm.search(name: newValue) }
            } else {
                vm.clear()
            }
        }
        .navigationDestination(item: $selectedManga) { manga in
            iPadMangaDetailView(manga: manga)
        }
    }
}

#Preview {
    NavigationStack {
        iPadSearchView()
    }
}
