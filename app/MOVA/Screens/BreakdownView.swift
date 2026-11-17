import SwiftUI
import MovaCore

/// Screen 05 — the shot list MOVA detected, plus the beat map.
struct BreakdownView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        let plan = model.plan
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: Space.m) {
                    ScreenHeader(eyebrow: "Reference · \(String(format: "%.1f", plan.totalDuration))s",
                                 title: "\(plan.shots.count) shots", onBack: { model.back() }) {
                        CircleIconButton(glyph: .slidersHorizontal, label: "Adjust shots") {}
                    }
                    .padding(.horizontal, -Space.gutter)

                    ForEach(Array(plan.shots.enumerated()), id: \.element.number) { i, shot in
                        shotCard(shot, index: i, isNext: i == 0)
                    }

                    beatCard(plan)

                    HStack(spacing: 6) {
                        Icon(.info, size: 16, color: .w52)
                        Text("Detected automatically. ").foregroundStyle(Color.w52)
                            + Text("Tap any shot to adjust.").foregroundStyle(.white)
                    }
                    .font(.movaCaption)
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, Space.gutter)
                .padding(.top, Space.s)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)

            Button {
                model.startRecreation()
            } label: {
                HStack(spacing: 8) { Icon(.videoCamera, .bold, size: 18); Text("Shoot shot 1") }
            }
            .buttonStyle(.movaPrimary)
            .padding(.horizontal, Space.gutter)
            .padding(.bottom, Space.s)
            .background(LinearGradient(colors: [.clear, .ink], startPoint: .top, endPoint: .center).ignoresSafeArea())
        }
        .background(Color.ink)
    }

    private func shotCard(_ shot: Shot, index: Int, isNext: Bool) -> some View {
        HStack(spacing: Space.s) {
            PhotoCrop(name: "fashion_yellow", scale: ShotCrop.scale(index), anchor: ShotCrop.anchor(index))
                .frame(width: 54, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(String(format: "%02d", shot.number))
                        .font(.movaMono(12, medium: true))
                        .foregroundStyle(isNext ? Color.coral : Color.w52)
                    if isNext {
                        Text("UP NEXT").font(.movaMono(10, medium: true)).foregroundStyle(.white)
                            .padding(.horizontal, 6).frame(height: 18)
                            .background(Color.coral, in: Capsule())
                    }
                }
                Text(shot.name).font(.mova(16, .semibold)).foregroundStyle(.white)
                HStack(spacing: 8) {
                    Text(shot.framing.label)
                    HStack(spacing: 4) {
                        Icon(shot.move.glyph, size: 14, color: .w72)
                        Text(shot.move.label)
                    }
                }
                .font(.movaCaption)
                .foregroundStyle(Color.w72)
            }
            Spacer()
            Text("\(String(format: "%.1f", shot.duration))s")
                .font(.movaMono(13, medium: true))
                .foregroundStyle(.white)
        }
        .padding(Space.s)
        .raisedCard(radius: 18)
        .overlay {
            if isNext {
                RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Color.coral.opacity(0.7), lineWidth: 1.5)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func beatCard(_ plan: ShotPlan) -> some View {
        VStack(alignment: .leading, spacing: Space.s) {
            HStack {
                Text("Beat map").font(.mova(15, .semibold)).foregroundStyle(.white)
                Spacer()
                HStack(spacing: 4) {
                    Circle().fill(Color.sun).frame(width: 6, height: 6)
                    Text("\(Int(model.beat.bpm)) BPM").foregroundStyle(Color.w72)
                    Text("· cuts on the beat").foregroundStyle(Color.w52)
                }
                .font(.movaMono(11))
            }
            BeatMapView(plan: plan, beat: model.beat)
                .frame(height: 64)
            HStack(spacing: 0) {
                ForEach(plan.shots) { s in
                    Text("\(s.number) · \(String(format: "%.1f", s.duration))s")
                        .font(.movaMono(10))
                        .foregroundStyle(Color.w52)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(Space.m)
        .raisedCard()
    }
}

#Preview {
    BreakdownView().environment(AppModel())
}
