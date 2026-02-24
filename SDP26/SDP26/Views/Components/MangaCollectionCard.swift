//
//  MangaCollectionCard.swift
//  SDP26
//
//  Created by José Luis Corral López on 2/2/26.
//

import SwiftUI

struct MangaCollectionCard: View {
    let totalVolumes: Int
    @Binding var volumesOwned: Set<Int>
    @Binding var readingVolume: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            progressBar
            volumesGrid
            Divider()
            readingProgress
        }
        .card()
    }

    private var header: some View {
        HStack {
            Text("My Collection").sectionTitle()
            Spacer()
            Text("\(volumesOwned.count)/\(totalVolumes) volumes").subtitleStyle()
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.secondary.opacity(0.2))
                RoundedRectangle(cornerRadius: 4)
                    .fill(.green)
                    .frame(width: geo.size.width * (Double(volumesOwned.count) / Double(totalVolumes)))
            }
        }
        .frame(height: 8)
    }

    private var volumesGrid: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Volumes owned").subtitleStyle()

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 44, maximum: 50), spacing: 6)], spacing: 6) {
                ForEach(1...totalVolumes, id: \.self) { volume in
                    VolumeButton(volume: volume, isOwned: volumesOwned.contains(volume)) {
                        toggleVolume(volume)
                    }
                }
            }
        }
    }

    private var readingProgress: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Currently reading").subtitleStyle()

            if volumesOwned.isEmpty {
                Text("Add volumes to your collection to track reading progress")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 0) {
                    ReadingOptionRow(title: "None", isSelected: readingVolume == nil) {
                        readingVolume = nil
                    }

                    ForEach(Array(volumesOwned).sorted(), id: \.self) { volume in
                        Divider().padding(.leading, 44)
                        ReadingOptionRow(title: "Volume \(volume)", isSelected: readingVolume == volume) {
                            readingVolume = volume
                        }
                    }
                }
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private func toggleVolume(_ volume: Int) {
        if volumesOwned.contains(volume) {
            volumesOwned.remove(volume)
            if readingVolume == volume { readingVolume = nil }
        } else {
            volumesOwned.insert(volume)
        }
    }
}

#Preview {
    MangaCollectionCard(
        totalVolumes: 41,
        volumesOwned: .constant([1, 2, 3]),
        readingVolume: .constant(2)
    )
    .padding()
}
