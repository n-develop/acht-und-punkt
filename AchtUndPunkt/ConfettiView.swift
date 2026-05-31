//
//  ConfettiView.swift
//  AchtUndPunkt
//

import SwiftUI

struct ConfettiView: View {
    let pieceCount: Int
    @State private var pieces: [ConfettiPiece] = []

    init(pieceCount: Int = 90) {
        self.pieceCount = pieceCount
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    ConfettiPieceView(piece: piece, canvasSize: geo.size)
                }
            }
            .onAppear {
                pieces = (0..<pieceCount).map { _ in ConfettiPiece.random(in: geo.size) }
            }
        }
        .allowsHitTesting(false)
    }
}

struct ConfettiPiece: Identifiable {
    enum Kind: CaseIterable { case rectangle, capsule, ellipse }

    let id = UUID()
    var startX: CGFloat
    var color: Color
    var size: CGFloat
    var duration: Double
    var delay: Double
    var rotation: Double
    var rotationSpeed: Double
    var drift: CGFloat
    var kind: Kind

    static func random(in size: CGSize) -> ConfettiPiece {
        let colors: [Color] = [.yellow, .orange, .pink, .cyan, .green, .purple, .red, .mint]
        return ConfettiPiece(
            startX: CGFloat.random(in: 0...size.width),
            color: colors.randomElement() ?? .yellow,
            size: CGFloat.random(in: 6...12),
            duration: Double.random(in: 2.5...4.5),
            delay: Double.random(in: 0...2.0),
            rotation: Double.random(in: 0...360),
            rotationSpeed: Double.random(in: 180...720),
            drift: CGFloat.random(in: -80...80),
            kind: Kind.allCases.randomElement() ?? .rectangle
        )
    }
}

private struct ConfettiPieceView: View {
    let piece: ConfettiPiece
    let canvasSize: CGSize
    @State private var animate = false

    var body: some View {
        shape
            .frame(width: piece.size, height: piece.size * 1.4)
            .position(
                x: piece.startX + (animate ? piece.drift : 0),
                y: animate ? canvasSize.height + 40 : -40
            )
            .rotationEffect(.degrees(animate ? piece.rotation + piece.rotationSpeed * piece.duration : piece.rotation))
            .opacity(animate ? 0.9 : 0)
            .onAppear {
                withAnimation(
                    .easeIn(duration: piece.duration)
                    .delay(piece.delay)
                    .repeatForever(autoreverses: false)
                ) {
                    animate = true
                }
            }
    }

    @ViewBuilder
    private var shape: some View {
        switch piece.kind {
        case .rectangle:
            Rectangle().fill(piece.color)
        case .capsule:
            Capsule().fill(piece.color)
        case .ellipse:
            Ellipse().fill(piece.color)
        }
    }
}
