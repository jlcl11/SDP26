//
//  AuthorsListView.swift
//  SDP26
//
//  Created by José Luis Corral López on 28/1/26.
//

import SwiftUI

struct AuthorsListView: View {
    @Bindable var authorVM = AuthorViewModel.shared

    var body: some View {
        NavigationStack {
            List(authorVM.authors) { author in
                Text(author.fullName)
                    .onAppear {
                        Task {
                            await authorVM.loadNextPageIfNeeded(for: author)
                        }
                    }
            }
            .navigationTitle("Authors")
            .searchable(text: $authorVM.searchText)
            .overlay {
                if authorVM.isLoading && authorVM.authors.isEmpty {
                    ProgressView()
                } else if authorVM.authors.isEmpty {
                    if authorVM.isSearching {
                        EmptyStateView.noSearchResults(for: authorVM.searchText, type: .author)
                    } else {
                        EmptyStateView.noContent(type: .author)
                    }
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
