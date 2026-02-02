//
//  CustomSearchSheet.swift
//  SDP26
//
//  Created by José Luis Corral López on 31/1/26.
//

import SwiftUI

struct CustomSearchSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Bindable var formVM = SearchFormViewModel.shared
    var onSearch: (CustomSearch) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Manga title", text: $formVM.searchTitle)
                }

                Section("Author") {
                    TextField("First name", text: $formVM.searchAuthorFirstName)
                    TextField("Last name", text: $formVM.searchAuthorLastName)
                }

                MultiSelectMenu(title: "Genres", options: formVM.genres, selected: $formVM.selectedGenres)
                MultiSelectMenu(title: "Themes", options: formVM.themes, selected: $formVM.selectedThemes)
                MultiSelectMenu(title: "Demographics", options: formVM.demographics, selected: $formVM.selectedDemographics)

                Section("Search Mode") {
                    Toggle("Contains (instead of begins with)", isOn: $formVM.searchContains)
                }
            }
            .navigationTitle("Advanced Search")
            .navigationBarTitleDisplayMode(.inline)
            .confirmButton {
                    onSearch(formVM.buildSearch())
                    dismiss()
            }
            .task {
                await formVM.loadOptions()
            }
        }
    }
}
