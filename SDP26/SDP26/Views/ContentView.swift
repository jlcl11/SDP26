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

    var mangaVM = MangaViewModel.shared

    var body: some View {
        TabView {
            Tab("Mangas", systemImage: "book.fill") {
                List(mangaVM.mangas) { manga in
                    Text(manga.title)
                        .onAppear {
                            if manga.id == mangaVM.mangas.last?.id {
                                Task {
                                    await mangaVM.loadNextPage()
                                }
                            }
                        }
                }
                .overlay {
                    if mangaVM.isLoading && mangaVM.mangas.isEmpty {
                        ProgressView()
                    }
                }
                .task {
                    await mangaVM.loadNextPage()
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
