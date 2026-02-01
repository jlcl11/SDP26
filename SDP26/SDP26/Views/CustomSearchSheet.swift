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

                Section("Genres") {
                    Menu {
                        ForEach(formVM.genres, id: \.self) { genre in
                            Button {
                                formVM.toggleGenre(genre)
                            } label: {
                                HStack {
                                    Text(genre)
                                    if formVM.selectedGenres.contains(genre) {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(formVM.selectedGenresText)
                                .foregroundStyle(formVM.selectedGenres.isEmpty ? .secondary : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                        }
                    }
                }

                Section("Themes") {
                    Menu {
                        ForEach(formVM.themes, id: \.self) { theme in
                            Button {
                                formVM.toggleTheme(theme)
                            } label: {
                                HStack {
                                    Text(theme)
                                    if formVM.selectedThemes.contains(theme) {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(formVM.selectedThemesText)
                                .foregroundStyle(formVM.selectedThemes.isEmpty ? .secondary : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                        }
                    }
                }

                Section("Demographics") {
                    Menu {
                        ForEach(formVM.demographics, id: \.self) { demographic in
                            Button {
                                formVM.toggleDemographic(demographic)
                            } label: {
                                HStack {
                                    Text(demographic)
                                    if formVM.selectedDemographics.contains(demographic) {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(formVM.selectedDemographicsText)
                                .foregroundStyle(formVM.selectedDemographics.isEmpty ? .secondary : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                        }
                    }
                }

                Section("Search Mode") {
                    Toggle("Contains (instead of begins with)", isOn: $formVM.searchContains)
                }
            }
            .navigationTitle("Custom Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Search") {
                        onSearch(formVM.buildSearch())
                        dismiss()
                    }
                }
            }
            .task {
                await formVM.loadOptions()
            }
        }
    }
}
