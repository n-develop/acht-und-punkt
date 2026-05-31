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

struct SkyBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Theme.skyLight, Theme.sky],
            startPoint: .top,
            endPoint: .bottom
        )
        .overlay(alignment: .bottom) {
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
        .ignoresSafeArea()
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
