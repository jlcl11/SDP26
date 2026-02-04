//
//  ProfileView.swift
//  SDP26
//
//  Created by José Luis Corral López on 4/2/26.
//

import SwiftUI

struct ProfileView: View {
    @Bindable var vm = BestMangaViewModel.shared

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        Circle()
                            .fill(.blue.gradient)
                            .frame(width: 60, height: 60)
                            .overlay {
                                Text("J")
                                    .font(.title2.bold())
                                    .foregroundStyle(.white)
                            }

                        VStack(alignment: .leading) {
                            Text("user@example.com")
                                .font(.headline)
                            Text("User")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Session") {
                    Label("Connected", systemImage: "wifi")
                    Label("Token: 18h 30m", systemImage: "clock.arrow.circlepath")
                }

                Section("Summary") {
                    Label("\(vm.mangas.count) mangas", systemImage: "books.vertical.fill")
                    Label("42 volumes", systemImage: "book.fill")
                }

                Section("My Collection") {
                    NavigationLink {
                        CollectionCategoryView(title: "Complete", icon: "checkmark.circle.fill")
                    } label: {
                        Label("Complete collections", systemImage: "checkmark.circle.fill")
                    }

                    NavigationLink {
                        CollectionCategoryView(title: "Owned", icon: "bookmark.fill")
                    } label: {
                        Label("Owned", systemImage: "bookmark.fill")
                    }

                    NavigationLink {
                        CollectionCategoryView(title: "Reading", icon: "book.fill")
                    } label: {
                        Label("Currently reading", systemImage: "book.fill")
                    }
                }

                Section {
                    Button("Log out", role: .destructive) {
                        // TODO: Implement logout
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Profile")
            .task {
                if vm.mangas.isEmpty {
                    await vm.loadNextPage()
                }
            }
        }
    }
}

#Preview("Profile") {
    ProfileView()
}


