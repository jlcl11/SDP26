//
//  ContentView.swift
//  SDP26
//
//  Created by José Luis Corral López on 28/1/26.
//

import SwiftUI
import NetworkAPI

struct ContentView: View {
    @MainActor let isiPhone = UIDevice.current.userInterfaceIdiom == .phone
    @MainActor let isiPad = UIDevice.current.userInterfaceIdiom == .pad
    @Bindable var mangaVM = MangaViewModel.shared
    
    var body: some View {
        TabView {
            Tab("Mangas", systemImage: "book.fill") {
                NavigationStack {
                    List(mangaVM.mangas) { manga in
                        NavigationLink(value: manga) {
                            MangaRow(manga: manga)
                        }
                        .onAppear {
                            Task {
                                await mangaVM.loadNextPageIfNeeded(for: manga)
                            }
                        }
                    }
                    .navigationDestination(for: MangaDTO.self) { manga in
                        MangaDetailView(manga: manga)
                    }
                    .navigationTitle("Mangas")
                    .searchable(text: $mangaVM.searchText)
                    .overlay {
                        if mangaVM.isLoading && mangaVM.mangas.isEmpty {
                            ProgressView()
                        } else if mangaVM.mangas.isEmpty {
                            if mangaVM.isCustomSearchActive {
                                EmptyStateView.noFilterResults()
                            } else if mangaVM.isSearching {
                                EmptyStateView.noSearchResults(for: mangaVM.searchText, type: .manga)
                            } else {
                                EmptyStateView.noContent(type: .manga)
                            }
                        }
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
                        CustomSearchSheet { search in
                            Task { await mangaVM.performCustomSearch(search) }
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
