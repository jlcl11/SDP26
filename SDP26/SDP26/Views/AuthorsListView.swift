//
//  AuthorsListView.swift
//  SDP26
//
//  Created by José Luis Corral López on 28/1/26.
//

import SwiftUI

struct AuthorsListView: View {
    var authorVM = AuthorViewModel.shared

    var body: some View {
        List(authorVM.authors) { author in
            Text(author.fullName)
                .onAppear {
                    if author.id == authorVM.authors.last?.id {
                        Task {
                            await authorVM.loadNextPage()
                        }
                    }
                }
        }
        .overlay {
            if authorVM.isLoading && authorVM.authors.isEmpty {
                ProgressView()
            }
        }
        .task {
            await authorVM.loadNextPage()
        }
    }
}

#Preview {
    AuthorsListView()
}
