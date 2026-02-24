//
//  ThemeViewModel.swift
//  SDP26
//
//  Created by José Luis Corral López on 20/12/25.
//

import Foundation

@Observable
final class ThemeViewModel {
    static let shared = ThemeViewModel(dataSource: ThemeDataSource(repository: NetworkRepository()))

    private(set) var themes: [String] = []
    private(set) var isLoading = false
    private let dataSource: ThemeDataSource

    init(dataSource: ThemeDataSource) {
        self.dataSource = dataSource
    }

    func load() async {
        guard !isLoading, themes.isEmpty else { return }
        isLoading = true

        do {
            themes = try await dataSource.fetch()
        } catch { }

        isLoading = false
    }
}
