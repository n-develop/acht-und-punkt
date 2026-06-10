//
//  Theme.swift
//  AchtUndPunkt
//

import SwiftUI

enum Theme {
    static let sky = Color(red: 0.37, green: 0.77, blue: 0.88)
    static let skyLight = Color(red: 0.62, green: 0.87, blue: 0.95)
    static let grass = Color(red: 0.49, green: 0.76, blue: 0.26)
    static let grassDark = Color(red: 0.36, green: 0.60, blue: 0.19)
    static let coral = Color(red: 0.91, green: 0.52, blue: 0.24)
    static let sunny = Color(red: 0.96, green: 0.84, blue: 0.29)
    static let claret = Color(red: 0.90, green: 0.24, blue: 0.17)
    static let cream = Color(red: 0.98, green: 0.96, blue: 0.91)
    static let charcoal = Color(red: 0.22, green: 0.22, blue: 0.22)

    static let playerPalette: [Color] = [coral, sunny, grass, sky, .purple, .pink]

    static let playerSymbols: [String] = [
        "hare.fill",
        "bird.fill",
        "tortoise.fill",
        "dog.fill",
        "cat.fill",
        "pawprint.fill"
    ]
}

private struct CloudPlacement {
    let xFrac: CGFloat
    let yFrac: CGFloat
    let width: CGFloat
    let opacity: Double
    let drift: CGFloat
    let duration: Double
}

private let cloudPlacements: [CloudPlacement] = [
    CloudPlacement(xFrac: 0.05, yFrac: 0.04, width: 130, opacity: 1.0,  drift:  30, duration: 5),
    CloudPlacement(xFrac: 0.55, yFrac: 0.08, width: 105, opacity: 0.95, drift:  28, duration: 9),
    CloudPlacement(xFrac: 0.20, yFrac: 0.28, width: 100, opacity: 0.85, drift: -25, duration: 8),
    CloudPlacement(xFrac: 0.62, yFrac: 0.32, width: 90,  opacity: 0.8,  drift: -35, duration: 7),
    CloudPlacement(xFrac: 0.38, yFrac: 0.48, width: 115, opacity: 0.9,  drift:  20, duration: 12),
]

private struct DriftingCloud: View {
    let placement: CloudPlacement
    let baseX: CGFloat
    let baseY: CGFloat
    @State private var drifted = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        CloudView(width: placement.width, opacity: placement.opacity)
            .position(
                x: baseX + (drifted ? placement.drift : 0),
                y: baseY
            )
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(
                    .linear(duration: placement.duration)
                    .repeatForever(autoreverses: true)
                ) {
                    drifted = true
                }
            }
    }
}

struct SkyBackground: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [Theme.skyLight, Theme.sky],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Sun in upper-right corner
                Circle()
                    .fill(Theme.sunny)
                    .frame(width: 80, height: 80)
                    .shadow(color: .black.opacity(0.15), radius: 8)
                    .position(x: geo.size.width - 64, y: 64)

                // Clouds scattered across the upper sky
                ForEach(cloudPlacements.indices, id: \.self) { i in
                    let c = cloudPlacements[i]
                    DriftingCloud(
                        placement: c,
                        baseX: geo.size.width * c.xFrac + c.width / 2,
                        baseY: geo.size.height * c.yFrac + c.width * 0.25
                    )
                }

                // Ground
                VStack {
                    Spacer()
                    GroundShape()
                        .fill(Theme.grass)
                        .frame(height: 110)
                        .overlay(alignment: .top) {
                            GroundShape()
                                .stroke(Theme.grassDark, lineWidth: 4)
                                .frame(height: 110)
                        }
                        .ignoresSafeArea(edges: .bottom)
                }
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

struct GroundShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: rect.height))
        p.addLine(to: CGPoint(x: 0, y: rect.height * 0.55))
        p.addCurve(
            to: CGPoint(x: rect.width * 0.35, y: rect.height * 0.25),
            control1: CGPoint(x: rect.width * 0.08, y: rect.height * 0.50),
            control2: CGPoint(x: rect.width * 0.20, y: rect.height * 0.15)
        )
        p.addCurve(
            to: CGPoint(x: rect.width * 0.70, y: rect.height * 0.45),
            control1: CGPoint(x: rect.width * 0.50, y: rect.height * 0.40),
            control2: CGPoint(x: rect.width * 0.58, y: rect.height * 0.55)
        )
        p.addCurve(
            to: CGPoint(x: rect.width, y: rect.height * 0.30),
            control1: CGPoint(x: rect.width * 0.82, y: rect.height * 0.30),
            control2: CGPoint(x: rect.width * 0.92, y: rect.height * 0.22)
        )
        p.addLine(to: CGPoint(x: rect.width, y: rect.height))
        p.closeSubpath()
        return p
    }
}

struct CloudView: View {
    var width: CGFloat = 120
    var opacity: Double = 1.0

    var body: some View {
        let h = width * 0.5
        ZStack(alignment: .bottomLeading) {
            Circle()
                .frame(width: h * 0.9, height: h * 0.9)
                .offset(x: width * 0.12, y: 0)
            Circle()
                .frame(width: h * 1.1, height: h * 1.1)
                .offset(x: width * 0.32, y: h * 0.1)
            Circle()
                .frame(width: h * 0.8, height: h * 0.8)
                .offset(x: width * 0.6, y: h * 0.2)
            RoundedRectangle(cornerRadius: h * 0.3)
                .frame(width: width, height: h * 0.55)
        }
        .foregroundStyle(.white.opacity(opacity))
        .shadow(color: .black.opacity(0.10), radius: 5, y: 3)
    }
}

struct ClayLabel: View {
    let text: String
    var size: CGFloat = 64
    var fillColor: Color = .white
    var strokeColor: Color = Theme.charcoal
    var strokeWidth: CGFloat = 3
    var rotation: Double = 0

    var body: some View {
        ZStack {
            Text(text)
                .font(.system(size: size, weight: .black, design: .rounded))
                .foregroundStyle(strokeColor)
                .offset(x: strokeWidth, y: strokeWidth)
                .blur(radius: 0.3)
                .opacity(0.8)
            Text(text)
                .font(.system(size: size, weight: .black, design: .rounded))
                .foregroundStyle(fillColor)
        }
        .rotationEffect(.degrees(rotation))
        .shadow(color: .black.opacity(0.18), radius: 6, y: 4)
        // The shadow copy would make VoiceOver read the text twice
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
    }
}

struct ClayCard<Content: View>: View {
    var cornerRadius: CGFloat = 18
    var fill: Color = .white
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(fill)
                    .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 4)
            )
    }
}

struct ChunkyButtonStyle: ButtonStyle {
    var fill: Color = Theme.grass
    var foreground: Color = .white
    var disabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.title3, design: .rounded).weight(.heavy))
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Theme.charcoal.opacity(0.25))
                        .offset(y: 4)
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(disabled ? Color.gray.opacity(0.6) : fill)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(.white.opacity(0.4), lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
            .opacity(disabled ? 0.7 : 1.0)
    }
}
