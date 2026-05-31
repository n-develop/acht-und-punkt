//
//  ContentView.swift
//  AchtUndPunkt
//

import SwiftUI

struct ContentView: View {
    @State private var game = GameViewModel()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.12, blue: 0.30),
                    Color(red: 0.25, green: 0.10, blue: 0.45)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Group {
                switch game.phase {
                case .setup:
                    PlayerSetupView(game: game)
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                case .playing(let round):
                    RoundView(game: game, round: round)
                        .id(round)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                case .finished:
                    WinnerView(game: game)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.85), value: game.phase)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
