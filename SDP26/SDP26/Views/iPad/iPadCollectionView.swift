//
//  iPadCollectionView.swift
//  SDP26
//
//  Created by José Luis Corral López on 6/2/26.
//

import SwiftUI

struct iPadCollectionView: View {
    @Bindable var vm = BestMangaViewModel.shared
    @State private var selectedManga: MangaDTO?
    @State private var viewMode: ViewMode = .grid

    enum ViewMode: String, CaseIterable {
        case grid = "Grid"
        case list = "List"

        var icon: String {
            switch self {
            case .grid: "square.grid.2x2"
            case .list: "list.bullet"
            }
        }
    }

    private let columns = [
        GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 20)
    ]

    var body: some View {
        Group {
            if vm.isLoading && vm.mangas.isEmpty {
                ProgressView("Loading collection...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if vm.mangas.isEmpty {
                ContentUnavailableView(
                    "No mangas",
                    systemImage: "books.vertical",
                    description: Text("Your collection is empty. Add mangas from the Mangas tab.")
                )
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Stats Header
                        HStack(spacing: 24) {
                            CollectionStatCard(
                                title: "Total Mangas",
                                value: "\(vm.mangas.count)",
                                icon: "book.fill",
                                color: .blue
                            )
                            CollectionStatCard(
                                title: "Volumes",
                                value: "42",
                                icon: "books.vertical.fill",
                                color: .purple
                            )
                            CollectionStatCard(
                                title: "Reading",
                                value: "3",
                                icon: "bookmark.fill",
                                color: .orange
                            )
                            CollectionStatCard(
                                title: "Complete",
                                value: "5",
                                icon: "checkmark.circle.fill",
                                color: .green
                            )
                        }
                        .padding(.horizontal)

                        Divider()
                            .padding(.horizontal)

                        // Collection Grid/List
                        if viewMode == .grid {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(vm.mangas) { manga in
                                    Button {
                                        selectedManga = manga
                                    } label: {
                                        iPadMangaCard(manga: manga)
                                    }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            // TODO: Implement delete
                                        } label: {
                                            Label("Remove from Collection", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(vm.mangas) { manga in
                                    Button {
                                        selectedManga = manga
                                    } label: {
                                        iPadCollectionRow(manga: manga)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("My Collection")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Picker("View Mode", selection: $viewMode) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Image(systemName: mode.icon)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 100)
            }
        }
        .navigationDestination(item: $selectedManga) { manga in
            iPadMangaDetailView(manga: manga)
        }
        .task {
            if vm.mangas.isEmpty {
                await vm.loadNextPage()
            }
        }
    }
}

struct CollectionStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)
                .frame(width: 50, height: 50)
                .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(title)
                    .secondaryText()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }
}

struct iPadCollectionRow: View {
    let manga: MangaDTO

    var body: some View {
        HStack(spacing: 16) {
            CachedAsyncImage(url: manga.imageURL, width: 80, height: 110)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 6) {
                Text(manga.title)
                    .font(.headline)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text(manga.score.formatted(.number.precision(.fractionLength(1))))
                }
                .subtitleStyle()

                Text(manga.status.displayName)
                    .badge(manga.status == .currentlyPublishing ? .green : .blue)

                if let volumes = manga.volumes {
                    Text("\(volumes) volumes")
                        .secondaryText()
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)

                ProgressView(value: 0.6)
                    .frame(width: 100)
            }
        }
        .card()
    }
}

#Preview {
    NavigationStack {
        iPadCollectionView()
    }
}
