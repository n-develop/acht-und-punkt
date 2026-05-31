//
//  PlayerSetupView.swift
//  AchtUndPunkt
//

import SwiftUI

struct PlayerSetupView: View {
    @Bindable var game: GameViewModel
    @FocusState private var focusedField: UUID?

    var body: some View {
        VStack(spacing: 24) {
            header

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Array(game.players.enumerated()), id: \.element.id) { index, player in
                        playerRow(index: index, playerID: player.id)
                    }

                    if game.canAddPlayer {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                game.addPlayer()
                            }
                            DispatchQueue.main.async {
                                focusedField = game.players.last?.id
                            }
                        } label: {
                            Label("Spieler hinzufügen", systemImage: "plus.circle.fill")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.white.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                                )
                        }
                    }
                }
                .padding(.horizontal, 20)
            }

            startButton
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("8 und Aus!")
                .font(.system(size: 44, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange, .pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: .black.opacity(0.4), radius: 6, y: 3)

            Text("Wer spielt mit?")
                .font(.title3.weight(.medium))
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(.top, 32)
    }

    private func playerRow(index: Int, playerID: UUID) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(playerColor(for: index))
                    .frame(width: 40, height: 40)
                Text("\(index + 1)")
                    .font(.headline.bold())
                    .foregroundStyle(.white)
            }

            TextField(
                "",
                text: Binding(
                    get: { game.players[index].name },
                    set: { game.players[index].name = $0 }
                ),
                prompt: Text("Spieler \(index + 1)").foregroundStyle(.white.opacity(0.5))
            )
            .font(.title3.weight(.medium))
            .foregroundStyle(.white)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .submitLabel(.next)
            .focused($focusedField, equals: playerID)

            if game.canRemovePlayer {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        game.removePlayer(at: index)
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white.opacity(0.12))
        )
    }

    private var startButton: some View {
        Button {
            withAnimation {
                game.startGame()
            }
        } label: {
            HStack {
                Image(systemName: "play.fill")
                Text("Spiel starten")
            }
            .font(.title3.weight(.bold))
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .opacity(game.canStartGame ? 1.0 : 0.4)
        }
        .disabled(!game.canStartGame)
    }

    private func playerColor(for index: Int) -> Color {
        let palette: [Color] = [
            .pink, .orange, .yellow, .green, .cyan, .purple
        ]
        return palette[index % palette.count]
    }
}

#Preview {
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
        PlayerSetupView(game: GameViewModel())
    }
    .preferredColorScheme(.dark)
}
