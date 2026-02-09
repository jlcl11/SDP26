//
//  SearchView.swift
//  SDP26
//
//  Created by José Luis Corral López on 4/2/26.
//

import SwiftUI

struct SearchView: View {
    @Bindable var vm = MangaBeginsWithViewModel.shared
    @State private var searchText = ""
    @State private var selectedManga: MangaDTO?
    private var networkMonitor = NetworkMonitor.shared

    var body: some View {
        NavigationStack {
            List {
                if !networkMonitor.isConnected {
                    Section {
                        OfflineBanner(message: "No connection - Cannot search")
                    }
                    .listRowInsets(EdgeInsets())
                }

                ForEach(vm.mangas) { manga in
                    Button {
                        selectedManga = manga
                    } label: {
                        MangaRow(manga: manga)
                    }
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.plain)
            .overlay {
                if searchText.isEmpty {
                    ContentUnavailableView(
                        "Search Mangas",
                        systemImage: "magnifyingglass",
                        description: Text("Type a manga name to start searching")
                    )
                } else if vm.isLoading && vm.mangas.isEmpty {
                    ProgressView("Searching...")
                } else if vm.mangas.isEmpty {
                    ContentUnavailableView(
                        "No results",
                        systemImage: "magnifyingglass",
                        description: Text("No mangas found matching \"\(searchText)\"")
                    )
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
                MangaDetailView(manga: manga)
            }
        }
    }
}

#Preview {
    SearchView()
}
