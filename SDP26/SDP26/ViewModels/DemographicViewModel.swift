//
//  DemographicViewModel.swift
//  SDP26
//
//  Created by José Luis Corral López on 31/1/26.
//

import Foundation

@Observable
final class DemographicViewModel {
    static let shared = DemographicViewModel(dataSource: DemographicDataSource(repository: NetworkRepository()))

    private(set) var demographics: [DemographicDTO] = []
    private(set) var isLoading = false
    private let dataSource: DemographicDataSource

    init(dataSource: DemographicDataSource) {
        self.dataSource = dataSource
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true

        do {
            demographics = try await dataSource.fetch()
        } catch {
            print("Error: \(error)")
        }

        isLoading = false
    }
}
