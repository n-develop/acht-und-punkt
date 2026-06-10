//
//  ScoreKeypad.swift
//  AchtUndPunkt
//

import SwiftUI

/// A custom number pad used to enter round scores, styled to match the
/// claymation theme. Besides the digits 0–9 and a delete key it offers a big
/// "Acht und aus!" button that enters 16 points in one tap.
struct ScoreKeypad: View {
    let playerName: String
    let playerColor: Color
    let playerSymbol: String
    let currentValue: String
    let isAchtUndAus: Bool
    let isLastPlayer: Bool

    var onDigit: (Int) -> Void
    var onDelete: () -> Void
    var onAchtUndAus: () -> Void
    var onNext: () -> Void
    var onDismiss: () -> Void

    private enum Key: Hashable {
        case digit(Int)
        case delete
        case next
    }

    private let layout: [[Key]] = [
        [.digit(1), .digit(2), .digit(3)],
        [.digit(4), .digit(5), .digit(6)],
        [.digit(7), .digit(8), .digit(9)],
        [.delete, .digit(0), .next]
    ]

    var body: some View {
        VStack(spacing: 12) {
            header
            keyGrid
            achtUndAusButton
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 22)
        .frame(maxWidth: 460)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Theme.cream)
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(.white.opacity(0.6), lineWidth: 1.5)
                )
                .shadow(color: .black.opacity(0.22), radius: 14, y: -2)
        )
        .padding(.horizontal, 10)
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(playerColor)
                    .frame(width: 40, height: 40)
                    .overlay(Circle().stroke(.white, lineWidth: 2))
                    .shadow(color: .black.opacity(0.12), radius: 2, y: 1)
                Image(systemName: playerSymbol)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
            }

            Text(playerName)
                .font(.system(.headline, design: .rounded).weight(.heavy))
                .foregroundStyle(Theme.charcoal)
                .lineLimit(1)

            Spacer()

            Text(currentValue.isEmpty ? "–" : currentValue)
                .font(.system(.title, design: .rounded).weight(.black))
                .foregroundStyle(isAchtUndAus ? Theme.coral : Theme.charcoal)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: currentValue)

            Button(action: onDismiss) {
                Image(systemName: "chevron.down.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Theme.charcoal.opacity(0.35))
            }
            .accessibilityLabel("Tastatur schließen")
        }
        .padding(.horizontal, 4)
    }

    private var keyGrid: some View {
        VStack(spacing: 10) {
            ForEach(layout.indices, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(layout[row], id: \.self) { key in
                        keyButton(key)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func keyButton(_ key: Key) -> some View {
        switch key {
        case .digit(let value):
            Button {
                onDigit(value)
            } label: {
                Text("\(value)")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(Theme.charcoal)
            }
            .buttonStyle(KeypadKeyStyle())

        case .delete:
            Button(action: onDelete) {
                Image(systemName: "delete.left.fill")
                    .font(.title2.weight(.heavy))
                    .foregroundStyle(Theme.charcoal.opacity(0.75))
            }
            .buttonStyle(KeypadKeyStyle(fill: Theme.charcoal.opacity(0.08)))
            .accessibilityLabel("Löschen")

        case .next:
            Button(action: onNext) {
                Image(systemName: isLastPlayer ? "checkmark" : "arrow.right")
                    .font(.title2.weight(.heavy))
                    .foregroundStyle(.white)
            }
            .buttonStyle(KeypadKeyStyle(fill: Theme.grass))
            .accessibilityLabel(isLastPlayer ? "Fertig" : "Nächster Spieler")
        }
    }

    private var achtUndAusButton: some View {
        Button(action: onAchtUndAus) {
            HStack(spacing: 12) {
                Image(systemName: "star.circle.fill")
                    .font(.title.weight(.bold))
                Text("Acht und aus!")
                    .font(.system(.title3, design: .rounded).weight(.black))
                Spacer()
                Text("16")
                    .font(.system(.title2, design: .rounded).weight(.black))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(.white.opacity(0.3))
                    )
                    .padding(.trailing, 10)
            }
            .foregroundStyle(.white)
            .padding(.leading, 6)
        }
        .buttonStyle(KeypadKeyStyle(
            fill: isAchtUndAus ? Theme.coral : Theme.coral.opacity(0.9),
            height: 60,
            cornerRadius: 20
        ))
    }
}

/// Chunky raised key styled like the rest of the claymation UI.
struct KeypadKeyStyle: ButtonStyle {
    var fill: Color = .white
    var height: CGFloat = 54
    var cornerRadius: CGFloat = 16

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Theme.charcoal.opacity(0.18))
                        .offset(y: 3)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(fill)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .stroke(Theme.charcoal.opacity(0.12), lineWidth: 1)
                        )
                }
            )
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .offset(y: configuration.isPressed ? 2 : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        SkyBackground()
        VStack {
            Spacer()
            ScoreKeypad(
                playerName: "Anna",
                playerColor: Theme.coral,
                playerSymbol: "hare.fill",
                currentValue: "12",
                isAchtUndAus: false,
                isLastPlayer: false,
                onDigit: { _ in },
                onDelete: {},
                onAchtUndAus: {},
                onNext: {},
                onDismiss: {}
            )
        }
    }
}
