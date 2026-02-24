//
//  MangaDetailComponents.swift
//  SDP26
//
//  Created by José Luis Corral López on 2/2/26.
//

import SwiftUI

struct InfoCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)

            Text(value)
                .font(.headline)

            Text(title)
                .secondaryText()
        }
        .frame(maxWidth: .infinity)
        .card()
    }
}

struct TagRow: View {
    let title: String
    let tags: [String]

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag).tagStyle()
                }
            }
        }
        .scrollIndicators(.hidden)
        .sectionHeader(title)
    }
}

struct VolumeButton: View {
    let volume: Int
    let isOwned: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text("\(volume)")
                .font(.caption)
                .fontWeight(.semibold)
                .frame(width: 44, height: 36)
                .background(isOwned ? .green : .secondary.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
                .foregroundStyle(isOwned ? .white : .primary)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isOwned)
    }
}

struct ReadingOptionRow: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: isSelected ? "book.fill" : "book")
                    .foregroundStyle(isSelected ? .blue : .secondary)
                    .frame(width: 24)

                Text(title)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.blue)
                        .fontWeight(.semibold)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview("InfoCard") {
    InfoCard(title: "Chapters", value: "364", icon: "book.pages")
        .padding()
}

#Preview("TagRow") {
    TagRow(title: "Genres", tags: ["Action", "Adventure", "Fantasy"])
        .padding()
}

#Preview("VolumeButton") {
    HStack {
        VolumeButton(volume: 1, isOwned: true) {}
        VolumeButton(volume: 2, isOwned: false) {}
    }
    .padding()
}
