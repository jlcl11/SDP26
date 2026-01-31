//
//  ThemeViewModel.swift
//  SDP26
//
//  Created by José Luis Corral López on 31/1/26.
//

import Foundation

@Observable
final class ThemeViewModel {
    static let shared = ThemeViewModel(dataSource: ThemeDataSource(repository: NetworkRepository()))

    private(set) var themes: [ThemeDTO] = []
    private(set) var isLoading = false
    private let dataSource: ThemeDataSource

    init(dataSource: ThemeDataSource) {
        self.dataSource = dataSource
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true

        do {
            themes = try await dataSource.fetch()
        } catch {
            print("Error: \(error)")
        }

        isLoading = false
    }
}
