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
    
    var body: some View {
        TabView {
            /*Tab("Mangas", systemImage: "book.fill") {
                if isiPhone {
                    MangasListView()
                } else {
                    MangasListViewiPad()
                }
            }

            Tab("Buscar", systemImage: "magnifyingglass", role: .search) {
                if isiPhone {
                    SearchView()
                } else {
                    SearchViewiPad()
                }
            }*/

            Tab("Authors", systemImage: "person.2") {
                if isiPhone {
                    AuthorsListView()
                } else {
                  //  AuthorsListViewiPad()
                }
            }
/*
            Tab("Colección", systemImage: "books.vertical") {
                if isiPhone {
                    CollectionView()
                } else {
                    CollectionViewiPad()
                }
            }

            Tab("Perfil", systemImage: "person.circle") {
                if isiPhone {
                    ProfileView()
                } else {
                    ProfileViewiPad()
                }
            }*/
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}

#Preview {
    ContentView()
}
