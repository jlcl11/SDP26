//
//  iPadAuthorsListView.swift
//  SDP26
//
//  Created by José Luis Corral López on 6/2/26.
//

import SwiftUI

struct iPadAuthorsListView: View {
    @Bindable var authorVM = AuthorViewModel.shared
    @State private var selectedAuthor: AuthorDTO?

    var body: some View {
        HStack(spacing: 0) {
            // Authors List
            VStack(spacing: 0) {
                List(authorVM.authors, selection: $selectedAuthor) { author in
                    iPadAuthorRow(author: author, isSelected: selectedAuthor?.id == author.id)
                        .tag(author)
                        .onAppear {
                            Task {
                                await authorVM.loadNextPageIfNeeded(for: author)
                            }
                        }
                }
                .listStyle(.plain)
                .frame(width: 320)
            }
            .background(Color(.systemGroupedBackground))

            Divider()

            // Author Detail
            if let author = selectedAuthor {
                iPadAuthorDetailView(author: author)
                    .frame(maxWidth: .infinity)
            } else {
                ContentUnavailableView(
                    "Select an Author",
                    systemImage: "person.crop.circle",
                    description: Text("Choose an author from the list to see their works")
                )
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Authors")
        .searchable(text: $authorVM.searchText, prompt: "Search authors...")
        .task {
            await authorVM.loadNextPage()
        }
    }
}

struct iPadAuthorRow: View {
    let author: AuthorDTO
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 16) {
            Text(author.firstName.prefix(1).uppercased() + author.lastName.prefix(1).uppercased())
                .avatar(size: 50)
                .background(isSelected ? .purple.gradient : .blue.gradient, in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(author.fullName)
                    .font(.headline)

                Label(author.role.rawValue, systemImage: author.role.icon)
                    .subtitleStyle()
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.blue)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack {
        iPadAuthorsListView()
    }
}
