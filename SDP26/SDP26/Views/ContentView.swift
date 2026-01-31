//
//  ContentView.swift
//  SDP26
//
//  Created by José Luis Corral López on 28/1/26.
//

import SwiftUI

struct ContentView: View {
    @MainActor let isiPhone = UIDevice.current.userInterfaceIdiom == .phone
    @MainActor let isiPad = UIDevice.current.userInterfaceIdiom == .pad

    @State private var searchText = ""
    var mangaVM = MangaViewModel.shared
    var searchVM = MangaBeginsWithViewModel.shared

    private var isSearching: Bool { searchText.count >= 2 }
    private var mangas: [MangaDTO] { isSearching ? searchVM.mangas : mangaVM.mangas }
    private var isLoading: Bool { isSearching ? searchVM.isLoading : mangaVM.isLoading }

    var body: some View {
        TabView {
            Tab("Mangas", systemImage: "book.fill") {
                NavigationStack {
                    List(mangas) { manga in
                        Text(manga.title)
                            .onAppear {
                                if !isSearching && manga.id == mangas.last?.id {
                                    Task {
                                        await mangaVM.loadNextPage()
                                    }
                                }
                            }
                    }
                    .navigationTitle("Mangas")
                    .searchable(text: $searchText)
                    .overlay {
                        if isLoading && mangas.isEmpty {
                            ProgressView()
                        }
                    }
                    .onChange(of: searchText) {
                        if searchText.count >= 2 {
                            Task { await searchVM.search(name: searchText) }
                        }
                    }
                    .task {
                        await mangaVM.loadNextPage()
                    }
                }
            }

            Tab("Authors", systemImage: "person.2") {
                if isiPhone {
                    AuthorsListView()
                } else {
                  //  AuthorsListViewiPad()
                }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}

#Preview {
    ContentView()
}
