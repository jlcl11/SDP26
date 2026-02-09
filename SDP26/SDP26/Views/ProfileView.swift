//
//  ProfileView.swift
//  SDP26
//
//  Created by José Luis Corral López on 4/2/26.
//

import SwiftUI

struct ProfileView: View {
    @State private var authVM = AuthViewModel.shared
    @State private var collectionVM = CollectionVM.shared
    private var networkMonitor = NetworkMonitor.shared

    var body: some View {
        NavigationStack {
            List {
                if !networkMonitor.isConnected {
                    Section {
                        OfflineBanner(message: "No connection - Some features unavailable")
                    }
                    .listRowInsets(EdgeInsets())
                }
                // User Info Section
                Section {
                    HStack(spacing: 16) {
                        Circle()
                            .fill(.blue.gradient)
                            .frame(width: 60, height: 60)
                            .overlay {
                                Text(userInitial)
                                    .font(.title2.bold())
                                    .foregroundStyle(.white)
                            }

                        VStack(alignment: .leading) {
                            Text(authVM.currentUser?.email ?? "Loading...")
                                .font(.headline)
                            Text(authVM.currentUser?.role.capitalized ?? "User")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                // Session Section
                Section("Session") {
                    if networkMonitor.isConnected {
                        Label("Connected", systemImage: "wifi")
                            .foregroundStyle(.green)
                    } else {
                        Label("Offline", systemImage: "wifi.slash")
                            .foregroundStyle(.orange)
                    }
                    if let timeRemaining = authVM.tokenTimeRemaining {
                        Label("Token: \(timeRemaining)", systemImage: "clock.arrow.circlepath")
                    }
                }

                // Collection Summary Section
                Section("Summary") {
                    Label("\(collectionVM.totalMangas) mangas", systemImage: "books.vertical.fill")
                    Label("\(collectionVM.totalVolumesOwned) volumes", systemImage: "book.fill")
                }

                // My Collection Section
                Section("My Collection") {
                    NavigationLink {
                        CollectionCategoryView(
                            title: "Complete",
                            icon: "checkmark.circle.fill",
                            items: collectionVM.completeCollections
                        )
                    } label: {
                        Label {
                            HStack {
                                Text("Complete collections")
                                Spacer()
                                Text("\(collectionVM.completeCollectionCount)")
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "checkmark.circle.fill")
                        }
                    }

                    NavigationLink {
                        CollectionCategoryView(
                            title: "Owned",
                            icon: "bookmark.fill",
                            items: collectionVM.owned
                        )
                    } label: {
                        Label {
                            HStack {
                                Text("Owned")
                                Spacer()
                                Text("\(collectionVM.totalMangas)")
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "bookmark.fill")
                        }
                    }

                    NavigationLink {
                        CollectionCategoryView(
                            title: "Reading",
                            icon: "book.fill",
                            items: collectionVM.currentlyReading
                        )
                    } label: {
                        Label {
                            HStack {
                                Text("Currently reading")
                                Spacer()
                                Text("\(collectionVM.currentlyReadingCount)")
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "book.fill")
                        }
                    }
                }

                // Logout Section
                Section {
                    Button("Log out", role: .destructive) {
                        Task {
                            await authVM.logout()
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Profile")
            .task {
                // Fetch user data lazily when ProfileView appears
                if authVM.currentUser == nil {
                    await authVM.fetchCurrentUser()
                }
                await collectionVM.loadCollection()
            }
            .refreshable {
                await authVM.fetchCurrentUser()
                await collectionVM.loadCollection()
            }
        }
    }

    private var userInitial: String {
        guard let email = authVM.currentUser?.email,
              let firstChar = email.first else {
            return "?"
        }
        return String(firstChar).uppercased()
    }
}

#Preview("Profile") {
    ProfileView()
}


