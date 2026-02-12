//
//  StatusBanner.swift
//  SDP26
//
//  Reusable status banner component for displaying sync states, pending changes, etc.
//

import SwiftUI

struct StatusBanner: View {
    let text: String
    let color: Color
    let icon: BannerIcon

    enum BannerIcon {
        case systemImage(String)
        case progress
    }

    var body: some View {
        HStack(spacing: 8) {
            switch icon {
            case .systemImage(let name):
                Image(systemName: name)
            case .progress:
                ProgressView()
                    .scaleEffect(0.8)
            }
            Text(text)
        }
        .font(.caption)
        .foregroundStyle(color)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.1))
    }
}

// MARK: - Factory Methods

extension StatusBanner {
    static func syncing() -> StatusBanner {
        StatusBanner(
            text: "Syncing changes...",
            color: .blue,
            icon: .progress
        )
    }

    static func pendingChanges(count: Int) -> StatusBanner {
        StatusBanner(
            text: "\(count) pending change(s) - Pull to sync",
            color: .orange,
            icon: .systemImage("arrow.triangle.2.circlepath")
        )
    }

    static func offline() -> StatusBanner {
        StatusBanner(
            text: "Offline - Showing cached data",
            color: .secondary,
            icon: .systemImage("wifi.slash")
        )
    }
}

#Preview {
    VStack(spacing: 0) {
        StatusBanner.syncing()
        StatusBanner.pendingChanges(count: 3)
        StatusBanner.offline()
    }
}
