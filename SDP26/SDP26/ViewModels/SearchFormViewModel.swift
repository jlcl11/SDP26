//
//  SearchFormViewModel.swift
//  SDP26
//
//  Created by José Luis Corral López on 31/1/26.
//

import Foundation

@Observable
final class SearchFormViewModel {
    static let shared = SearchFormViewModel(
        genreDataSource: GenreDataSource(repository: NetworkRepository()),
        themeDataSource: ThemeDataSource(repository: NetworkRepository()),
        demographicDataSource: DemographicDataSource(repository: NetworkRepository())
    )

    // Available options
    private(set) var genres: [String] = []
    private(set) var themes: [String] = []
    private(set) var demographics: [String] = []
    private(set) var isLoading = false

    // Selected options
    var selectedGenres: Set<String> = []
    var selectedThemes: Set<String> = []
    var selectedDemographics: Set<String> = []

    // Search fields
    var searchTitle: String = ""
    var searchAuthorFirstName: String = ""
    var searchAuthorLastName: String = ""
    var searchContains: Bool = false

    private let genreDataSource: GenreDataSource
    private let themeDataSource: ThemeDataSource
    private let demographicDataSource: DemographicDataSource

    init(genreDataSource: GenreDataSource, themeDataSource: ThemeDataSource, demographicDataSource: DemographicDataSource) {
        self.genreDataSource = genreDataSource
        self.themeDataSource = themeDataSource
        self.demographicDataSource = demographicDataSource
    }

    func loadOptions() async {
        guard genres.isEmpty else { return }
        isLoading = true

        async let g = genreDataSource.fetch()
        async let t = themeDataSource.fetch()
        async let d = demographicDataSource.fetch()

        do {
            genres = try await g
            themes = try await t
            demographics = try await d
        } catch {
            print("Error loading options: \(error)")
        }

        isLoading = false
    }

    func buildSearch() -> CustomSearch {
        CustomSearch(
            searchTitle: searchTitle.isEmpty ? nil : searchTitle,
            searchAuthorFirstName: searchAuthorFirstName.isEmpty ? nil : searchAuthorFirstName,
            searchAuthorLastName: searchAuthorLastName.isEmpty ? nil : searchAuthorLastName,
            searchGenres: selectedGenres.isEmpty ? nil : Array(selectedGenres),
            searchThemes: selectedThemes.isEmpty ? nil : Array(selectedThemes),
            searchDemographics: selectedDemographics.isEmpty ? nil : Array(selectedDemographics),
            searchContains: searchContains
        )
    }

    func reset() {
        searchTitle = ""
        searchAuthorFirstName = ""
        searchAuthorLastName = ""
        selectedGenres = []
        selectedThemes = []
        selectedDemographics = []
        searchContains = false
    }

}
