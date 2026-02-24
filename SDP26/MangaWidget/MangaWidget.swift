//
//  MangaWidget.swift
//  MangaWidget
//
//  Created by José Luis Corral López on 18/2/26.
//

import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Shared Model Container (matches main app)

enum SharedModelContainer {
    static let appGroupIdentifier = "group.prueba.offi"

    static func create() -> ModelContainer {
        let schema = Schema([
            MangaCollectionModel.self
        ])

        let configuration: ModelConfiguration

        if let appGroupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) {
            let storeURL = appGroupURL.appendingPathComponent("MangaCollection.store")
            configuration = ModelConfiguration(
                "MangaCollection",
                schema: schema,
                url: storeURL,
                cloudKitDatabase: .none
            )
        } else {
            configuration = ModelConfiguration(
                "MangaCollection",
                schema: schema,
                cloudKitDatabase: .none
            )
        }

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}

// MARK: - Reading Manga (for widget display)

struct ReadingManga: Identifiable {
    let id: Int
    let title: String
    let cachedImage: UIImage?
    let currentVolume: Int
    let totalVolumes: Int?

    var progress: Double {
        guard let total = totalVolumes, total > 0 else { return 0 }
        return Double(currentVolume) / Double(total)
    }

    var progressText: String {
        if let total = totalVolumes {
            return "Vol. \(currentVolume)/\(total)"
        }
        return "Vol. \(currentVolume)"
    }

    init(from model: MangaCollectionModel) {
        self.id = model.mangaId
        self.title = model.title
        self.currentVolume = model.readingVolume ?? 0
        self.totalVolumes = model.volumes

        // Load cached image from shared cache
        if let url = model.imageURL {
            self.cachedImage = SharedImageCache.shared.loadImage(for: url)
        } else {
            self.cachedImage = nil
        }
    }

    // For previews
    init(id: Int, title: String, cachedImage: UIImage? = nil, currentVolume: Int, totalVolumes: Int?) {
        self.id = id
        self.title = title
        self.cachedImage = cachedImage
        self.currentVolume = currentVolume
        self.totalVolumes = totalVolumes
    }
}

// MARK: - Timeline Entry

struct MangaEntry: TimelineEntry {
    let date: Date
    let readingMangas: [ReadingManga]

    static let placeholder = MangaEntry(
        date: Date(),
        readingMangas: [
            ReadingManga(id: 1, title: "Berserk", currentVolume: 15, totalVolumes: 41),
            ReadingManga(id: 2, title: "One Piece", currentVolume: 98, totalVolumes: 107),
            ReadingManga(id: 3, title: "Naruto", currentVolume: 45, totalVolumes: 72),
            ReadingManga(id: 4, title: "Dragon Ball", currentVolume: 20, totalVolumes: 42)
        ]
    )

    static let empty = MangaEntry(date: Date(), readingMangas: [])
}

// MARK: - Timeline Provider

struct Provider: @MainActor TimelineProvider {
    let modelContainer = SharedModelContainer.create()

    func placeholder(in context: Context) -> MangaEntry {
        MangaEntry.placeholder
    }

    @MainActor func getSnapshot(in context: Context, completion: @escaping (MangaEntry) -> ()) {
        let entry = fetchReadingMangas()
        completion(entry)
    }

    @MainActor func getTimeline(in context: Context, completion: @escaping (Timeline<MangaEntry>) -> ()) {
        let entry = fetchReadingMangas()

        // Refresh every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    @MainActor
    private func fetchReadingMangas() -> MangaEntry {
        let context = modelContainer.mainContext

        // Only fetch mangas that are currently being read
        let descriptor = FetchDescriptor<MangaCollectionModel>(
            predicate: #Predicate { $0.readingVolume != nil },
            sortBy: [SortDescriptor(\.title)]
        )

        do {
            let models = try context.fetch(descriptor)
            let readingMangas = models.map { ReadingManga(from: $0) }
            return MangaEntry(date: Date(), readingMangas: readingMangas)
        } catch {
            return MangaEntry.empty
        }
    }
}

// MARK: - Widget Views

struct MangaWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget (1 manga with progress)

struct SmallWidgetView: View {
    let entry: MangaEntry

    var body: some View {
        if let manga = entry.readingMangas.first {
            VStack(alignment: .leading, spacing: 6) {
                // Header
                HStack {
                    Image(systemName: "book.fill")
                        .font(.caption2)
                        .foregroundStyle(.blue)
                    Text("Reading")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                }

                HStack(spacing: 8) {
                    // Cover
                    MangaCoverView(image: manga.cachedImage, size: .small)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(manga.title)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .lineLimit(2)

                        Spacer()

                        Text(manga.progressText)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(.blue)

                        ProgressView(value: manga.progress)
                            .tint(.blue)
                    }
                }
            }
            .padding()
        } else {
            EmptyWidgetView()
        }
    }
}

// MARK: - Medium Widget (3 mangas with progress)

struct MediumWidgetView: View {
    let entry: MangaEntry

    var body: some View {
        if entry.readingMangas.isEmpty {
            EmptyWidgetView()
        } else {
            VStack(alignment: .leading, spacing: 8) {
                // Header
                HStack {
                    Image(systemName: "book.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    Text("Currently Reading")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(entry.readingMangas.count)")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.blue.opacity(0.2))
                        .clipShape(Capsule())
                }

                // Manga cards
                HStack(spacing: 10) {
                    ForEach(entry.readingMangas.prefix(3)) { manga in
                        MangaCardView(manga: manga)
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Large Widget (up to 5 mangas with detailed progress)

struct LargeWidgetView: View {
    let entry: MangaEntry

    var body: some View {
        if entry.readingMangas.isEmpty {
            EmptyWidgetView()
        } else {
            VStack(alignment: .leading, spacing: 10) {
                // Header
                HStack {
                    Image(systemName: "book.fill")
                        .foregroundStyle(.blue)
                    Text("Currently Reading")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(entry.readingMangas.count) manga\(entry.readingMangas.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Manga rows with progress
                ForEach(entry.readingMangas.prefix(5)) { manga in
                    MangaRowView(manga: manga)
                }

                if entry.readingMangas.count > 5 {
                    Text("+\(entry.readingMangas.count - 5) more")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                Spacer(minLength: 0)
            }
            .padding()
        }
    }
}

// MARK: - Supporting Views

struct MangaCoverView: View {
    let image: UIImage?

    enum Size {
        case small, medium, row

        var dimensions: (width: CGFloat, height: CGFloat) {
            switch self {
            case .small: return (45, 63)
            case .medium: return (40, 56)
            case .row: return (35, 49)
            }
        }
    }

    let size: Size

    var body: some View {
        if let uiImage = image {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.dimensions.width, height: size.dimensions.height)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        } else {
            RoundedRectangle(cornerRadius: 4)
                .fill(.secondary.opacity(0.2))
                .frame(width: size.dimensions.width, height: size.dimensions.height)
                .overlay {
                    Image(systemName: "book.closed.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
        }
    }
}

struct MangaCardView: View {
    let manga: ReadingManga

    var body: some View {
        VStack(spacing: 4) {
            MangaCoverView(image: manga.cachedImage, size: .medium)

            Text(manga.title)
                .font(.system(size: 9))
                .lineLimit(1)

            Text(manga.progressText)
                .font(.system(size: 8))
                .fontWeight(.medium)
                .foregroundStyle(.blue)
        }
        .frame(maxWidth: .infinity)
    }
}

struct MangaRowView: View {
    let manga: ReadingManga

    var body: some View {
        HStack(spacing: 10) {
            MangaCoverView(image: manga.cachedImage, size: .row)

            VStack(alignment: .leading, spacing: 3) {
                Text(manga.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)

                HStack {
                    Text(manga.progressText)
                        .font(.caption2)
                        .foregroundStyle(.blue)

                    Spacer()

                    // Percentage
                    if manga.totalVolumes != nil {
                        Text("\(Int(manga.progress * 100))%")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                ProgressView(value: manga.progress)
                    .tint(.blue)
            }
        }
    }
}

struct EmptyWidgetView: View {
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "book.closed")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("No manga in progress")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Start reading to track progress")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding()
    }
}

// MARK: - Widget Configuration

struct MangaWidget: Widget {
    let kind: String = "MangaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                MangaWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                MangaWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Reading Progress")
        .description("Track your currently reading mangas and progress.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    MangaWidget()
} timeline: {
    MangaEntry.placeholder
}

#Preview("Medium", as: .systemMedium) {
    MangaWidget()
} timeline: {
    MangaEntry.placeholder
}

#Preview("Large", as: .systemLarge) {
    MangaWidget()
} timeline: {
    MangaEntry.placeholder
}

#Preview("Empty", as: .systemSmall) {
    MangaWidget()
} timeline: {
    MangaEntry.empty
}
