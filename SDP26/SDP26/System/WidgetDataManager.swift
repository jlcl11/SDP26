//
//  WidgetDataManager.swift
//  SDP26
//
//  Manages widget timeline refreshes.
//  The widget reads directly from the shared SwiftData container.
//

import Foundation
import WidgetKit

// MARK: - Widget Data Manager

@MainActor
final class WidgetDataManager {
    static let shared = WidgetDataManager()

    private init() {}

    /// Notifies the widget to refresh its timeline
    func refreshWidget() {
        WidgetCenter.shared.reloadTimelines(ofKind: "MangaWidget")
    }

    /// Clears widget data (triggers refresh with potentially empty data)
    func clearWidgetData() {
        WidgetCenter.shared.reloadTimelines(ofKind: "MangaWidget")
    }
}
