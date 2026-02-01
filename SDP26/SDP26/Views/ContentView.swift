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
    @State private var showSearchSheet = false
    @State private var isCustomSearchActive = false

    var mangaVM = MangaViewModel.shared
    var searchVM = MangaBeginsWithViewModel.shared
    var customSearchVM = CustomSearchViewModel.shared

    private var isSearching: Bool { searchText.count >= 2 }

    private var mangas: [MangaDTO] {
        if isCustomSearchActive {
            return customSearchVM.mangas
        } else if isSearching {
            return searchVM.mangas
        } else {
            return mangaVM.mangas
        }
    }

    private var isLoading: Bool {
        if isCustomSearchActive {
            return customSearchVM.isLoading
        } else if isSearching {
            return searchVM.isLoading
        } else {
            return mangaVM.isLoading
        }
    }

    var body: some View {
        TabView {
            Tab("Mangas", systemImage: "book.fill") {
                NavigationStack {
                    List(mangas) { manga in
                        Text(manga.title)
                            .onAppear {
                                if manga.id == mangas.last?.id {
                                    Task {
                                        if isCustomSearchActive {
                                            await customSearchVM.loadNextPage()
                                        } else if !isSearching {
                                            await mangaVM.loadNextPage()
                                        }
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
                            isCustomSearchActive = false
                            Task { await searchVM.search(name: searchText) }
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button {
                                showSearchSheet = true
                            } label: {
                                Image(systemName: isCustomSearchActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            }
                        }
                    }
                    .sheet(isPresented: $showSearchSheet) {
                        CustomSearchSheet { search in
                            isCustomSearchActive = true
                            searchText = ""
                            Task { await customSearchVM.search(search) }
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
