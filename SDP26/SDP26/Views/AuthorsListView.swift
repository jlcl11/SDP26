//
//  AuthorsListView.swift
//  SDP26
//
//  Created by José Luis Corral López on 28/1/26.
//

import SwiftUI

struct AuthorsListView: View {
    @State private var searchText = ""
    var authorVM = AuthorViewModel.shared
    var searchVM = AuthorByNameViewModel.shared

    private var isSearching: Bool { searchText.count >= 2 }
    private var authors: [AuthorDTO] { isSearching ? searchVM.authors : authorVM.authors }
    private var isLoading: Bool { isSearching ? searchVM.isLoading : authorVM.isLoading }

    var body: some View {
        NavigationStack {
            List(authors) { author in
                Text(author.fullName)
                    .onAppear {
                        if !isSearching && author.id == authors.last?.id {
                            Task {
                                await authorVM.loadNextPage()
                            }
                        }
                    }
            }
            .navigationTitle("Authors")
            .searchable(text: $searchText)
            .overlay {
                if isLoading && authors.isEmpty {
                    ProgressView()
                }
            }
            .onChange(of: searchText) {
                if searchText.count >= 2 {
                    Task { await searchVM.search(name: searchText) }
                }
            }
            .task {
                await authorVM.loadNextPage()
            }
        }
    }
}

#Preview {
    AuthorsListView()
}
