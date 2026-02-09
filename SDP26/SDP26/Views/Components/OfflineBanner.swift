//
//  OfflineBanner.swift
//  SDP26
//
//  Reusable offline indicator banner.
//

import SwiftUI

struct OfflineBanner: View {
    var message: String = "No internet connection"

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
            Text(message)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    VStack {
        OfflineBanner()
        OfflineBanner(message: "Offline - Showing cached data")
    }
}
