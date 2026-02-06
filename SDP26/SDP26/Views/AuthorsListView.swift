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
                NavigationLink(value: author) {
                    AuthorRow(author: author)
                }
                .onAppear {
                    Task {
                        await authorVM.loadNextPageIfNeeded(for: author)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Authors")
            .navigationDestination(for: AuthorDTO.self) { author in
                AuthorDetailView(author: author)
            }
            .searchable(text: $authorVM.searchText, prompt: "Search authors...")
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

struct AuthorRow: View {
    let author: AuthorDTO

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.blue.gradient)
                .frame(width: 44, height: 44)
                .overlay {
                    Text(author.fullName.prefix(1).uppercased())
                        .font(.headline)
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(author.fullName)
                    .rowTitle()

                Text(author.role.rawValue.capitalized)
                    .secondaryText()
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AuthorsListView()
}
