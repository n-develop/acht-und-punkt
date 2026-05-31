//
//  AppIconView.swift
//  AchtUndPunkt
//

import SwiftUI

// MARK: - Icon design (scalable; default 1024 × 1024 for export)

struct AppIconView: View {
    var size: CGFloat = 1024

    private var s: CGFloat { size / 1024 }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Sky gradient
            LinearGradient(
                colors: [Theme.skyLight, Theme.sky],
                startPoint: .top,
                endPoint: .bottom
            )

            // Grass strip
            VStack(spacing: 0) {
                Theme.grassDark.frame(height: 10 * s)
                Theme.grass.frame(height: 180 * s)
            }

            // Logo
            VStack(spacing: -24 * s) {
                ClayLabel(text: "8", size: 560 * s, rotation: -4)
                HStack(alignment: .center, spacing: 18 * s) {
                    ClayLabel(text: "und", size: 90 * s, rotation: -1)
                    ClayLabel(text: "Punkt!", size: 150 * s, fillColor: Theme.sunny, rotation: 2)
                }
            }
            .offset(y: -130 * s)
        }
        .frame(width: size, height: size)
        .clipped()
    }
}

// MARK: - Export sheet

struct IconExportSheet: View {
    @State private var exportURL: URL? = nil

    var body: some View {
        VStack(spacing: 28) {
            Text("App Icon exportieren")
                .font(.system(.title2, design: .rounded).weight(.heavy))
                .foregroundStyle(Theme.charcoal)
                .padding(.top, 8)

            AppIconView(size: 280)
                .clipShape(RoundedRectangle(cornerRadius: 62, style: .continuous))
                .shadow(color: .black.opacity(0.25), radius: 24, y: 10)

            VStack(spacing: 6) {
                Text("1024 × 1024 px PNG")
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(Theme.charcoal.opacity(0.75))
                Text("In Xcode: Assets.xcassets → AppIcon → 1024 pt Slot")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Theme.charcoal.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            if let url = exportURL {
                ShareLink(
                    item: url,
                    preview: SharePreview("AppIcon_1024.png")
                ) {
                    Label("Als PNG teilen", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(ChunkyButtonStyle(fill: Theme.grass))
                .padding(.horizontal, 40)
            } else {
                ProgressView().padding()
            }

            Spacer()
        }
        .padding(.top, 32)
        .onAppear { renderAndStage() }
    }

    private func renderAndStage() {
        let renderer = ImageRenderer(content: AppIconView()) // 1024 × 1024
        renderer.proposedSize = .init(width: 1024, height: 1024)
        renderer.scale = 1.0

        guard let image = renderer.uiImage,
              let data = image.pngData() else { return }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("AppIcon_1024.png")
        try? data.write(to: url)
        exportURL = url
    }
}

// MARK: - Previews

#Preview("Export Sheet") {
    IconExportSheet()
}

#Preview("Icon 1:1") {
    AppIconView(size: 300)
        .clipShape(RoundedRectangle(cornerRadius: 66, style: .continuous))
        .padding(20)
}
