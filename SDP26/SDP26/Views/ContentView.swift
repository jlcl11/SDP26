//
//  ContentView.swift
//  SDP26
//
//  Created by José Luis Corral López on 8/1/26.
//

import SwiftUI
import NetworkAPI

struct ContentView: View {
    @MainActor let isiPhone = UIDevice.current.userInterfaceIdiom == .phone
    @MainActor let isiPad = UIDevice.current.userInterfaceIdiom == .pad

    var body: some View {
        if isiPad {
            iPadContentView()
        } else {
            iPhoneContentView()
        }
    }
}

struct iPhoneContentView: View {
    var body: some View {
        TabView {
            Tab("Mangas", systemImage: "book.fill") {
                MangaListView()
            }

            Tab("Authors", systemImage: "person.2") {
                AuthorsListView()
            }

            Tab("Collection", systemImage: "books.vertical") {
                CollectionView()
            }

            Tab("Profile", systemImage: "person.circle") {
                ProfileView()
            }

            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                SearchView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

#Preview("iPhone") {
    iPhoneContentView()
}

#Preview("iPad") {
    iPadContentView()
}
