import SwiftUI
import MovaCore
import PhosphorSwift

/// Screen 09 — Library tab (shows screen 15 when empty).
struct LibraryView: View {
    @Environment(AppModel.self) private var model
    @State private var filter: Filter = .all

    enum Filter: String, CaseIterable { case all = "All", recreations = "Recreations", photos = "Photos" }

    private var items: [LibraryItem] {
        model.library.filter { item in
            switch filter {
            case .all: true
            case .recreations: item.isRecreation
            case .photos: item.kind == .photo
            }
        }
    }

    var body: some View {
        if model.library.isEmpty {
            LibraryEmptyView()
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: Space.m) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Library").font(.movaTitle).foregroundStyle(.white)
                        Text("\(model.library.count)").font(.movaMono(14)).foregroundStyle(Color.w52)
                        Spacer()
                        CircleIconButton(glyph: .magnifyingGlass, label: "Search") {}
                    }
                    SegmentedPill(options: Filter.allCases, selection: $filter) { $0.rawValue }

                    if items.isEmpty {
                        Text("Nothing here yet.").font(.movaCallout).foregroundStyle(Color.w52)
                            .frame(maxWidth: .infinity, minHeight: 200)
                    } else {
                        masonry
                    }
                }
                .padding(.horizontal, Space.gutter)
                .padding(.top, Space.s)
                .clearsTabBar()
            }
            .scrollIndicators(.hidden)
            .background(Color.ink)
        }
    }

    private var masonry: some View {
        let heights: [CGFloat] = [230, 170, 190, 250, 210, 180]
        let indexed = Array(items.enumerated())
        return HStack(alignment: .top, spacing: Space.s) {
            ForEach(0..<2, id: \.self) { col in
                VStack(spacing: Space.m) {
                    ForEach(indexed.filter { $0.offset % 2 == col }, id: \.element.id) { i, item in
                        tile(item, height: heights[i % heights.count])
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func tile(_ item: LibraryItem, height: CGFloat) -> some View {
        Button {
            model.open(item.isRecreation ? .result : .editor)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                ZStack(alignment: .bottomLeading) {
                    SamplePhoto(name: item.photo)
                        .frame(height: height)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    HStack {
                        badge(item)
                        Spacer()
                        if case .recreation(_, let score) = item.kind {
                            ScoreBadge(score: score)
                        }
                    }
                    .padding(Space.xs)
                }
                Text(item.title).font(.mova(14, .semibold)).foregroundStyle(.white).lineLimit(1)
                Text(item.caption).font(.movaMono(11)).foregroundStyle(Color.w52).lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder private func badge(_ item: LibraryItem) -> some View {
        HStack(spacing: 4) {
            if let d = item.duration {
                Icon(.play, .fill, size: 11)
                Text(timecode(d).replacingOccurrences(of: ".0", with: "")).font(.movaMono(11, medium: true))
            } else {
                Icon(.image, size: 13)
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .frame(height: 24)
        .background(.black.opacity(0.5), in: Capsule())
    }
}

#Preview {
    LibraryView().environment(AppModel())
}
