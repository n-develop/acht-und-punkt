//
//  PlayerSetupView.swift
//  AchtUndPunkt
//

import SwiftUI

struct PlayerSetupView: View {
    @ObservedObject var game: GameViewModel
    @FocusState private var focusedField: UUID?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isIPad: Bool { horizontalSizeClass == .regular }

    var body: some View {
        VStack(spacing: isIPad ? 28 : 18) {
            header

            ScrollView {
                playerGrid
                    .padding(.horizontal, isIPad ? 40 : 20)
            }

            startButton
                .padding(.horizontal, isIPad ? 40 : 20)
                .padding(.bottom, 90)
        }
        .frame(maxWidth: isIPad ? 700 : .infinity)
    }

    private var header: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 10) {
                ClayLabel(text: "8", size: isIPad ? 120 : 96, rotation: -4)
                VStack(alignment: .leading, spacing: 2) {
                    ClayLabel(text: "und", size: isIPad ? 36 : 28, rotation: -1)
                    ClayLabel(text: "Punkt!", size: isIPad ? 72 : 56, fillColor: Theme.sunny, rotation: 2)
                }
            }
            .padding(.top, isIPad ? 40 : 28)

            SpeechBubble {
                Text("Wer spielt mit?")
                    .font(.system(isIPad ? .title : .title3, design: .rounded).weight(.heavy))
                    .foregroundStyle(.white)
            }
        }
    }

    @ViewBuilder
    private var playerGrid: some View {
        if isIPad {
            VStack(spacing: 12) {
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 12
                ) {
                    ForEach(Array(game.players.enumerated()), id: \.element.id) { index, player in
                        playerRow(index: index, playerID: player.id)
                    }
                }
                if game.canAddPlayer {
                    addPlayerButton
                }
            }
        } else {
            VStack(spacing: 12) {
                ForEach(Array(game.players.enumerated()), id: \.element.id) { index, player in
                    playerRow(index: index, playerID: player.id)
                }
                if game.canAddPlayer {
                    addPlayerButton
                }
            }
        }
    }

    private var addPlayerButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                game.addPlayer()
            }
            DispatchQueue.main.async {
                focusedField = game.players.last?.id
            }
        } label: {
            Label("Spieler hinzufügen", systemImage: "plus.circle.fill")
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundStyle(Theme.charcoal)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Theme.charcoal.opacity(0.4), style: StrokeStyle(lineWidth: 2, dash: [6]))
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(.white.opacity(0.55))
                        )
                )
        }
    }

    private func playerRow(index: Int, playerID: UUID) -> some View {
        ClayCard {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(playerColor(for: index))
                        .frame(width: 44, height: 44)
                        .overlay(Circle().stroke(.white, lineWidth: 2))
                        .shadow(color: .black.opacity(0.12), radius: 2, y: 2)
                    Image(systemName: playerSymbol(for: index))
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                }

                TextField(
                    "",
                    text: Binding(
                        get: { game.players[index].name },
                        set: { game.players[index].name = $0 }
                    ),
                    prompt: Text("Spieler \(index + 1)").foregroundColor(Theme.charcoal.opacity(0.4))
                )
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(Theme.charcoal)
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
                            .foregroundStyle(Theme.claret.opacity(0.85))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private var startButton: some View {
        Button {
            withAnimation {
                game.startGame()
            }
        } label: {
            Label("Spiel starten", systemImage: "play.fill")
        }
        .buttonStyle(ChunkyButtonStyle(disabled: !game.canStartGame))
        .disabled(!game.canStartGame)
    }

    private func playerColor(for index: Int) -> Color {
        Theme.playerPalette[index % Theme.playerPalette.count]
    }

    private func playerSymbol(for index: Int) -> String {
        Theme.playerSymbols[index % Theme.playerSymbols.count]
    }
}

struct SpeechBubble<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(.horizontal, 22)
            .padding(.vertical, 12)
            .background(
                BlobShape()
                    .fill(Theme.grass)
                    .shadow(color: .black.opacity(0.15), radius: 4, y: 3)
            )
    }
}

struct BlobShape: Shape {
    func path(in rect: CGRect) -> Path {
        let r = min(rect.width, rect.height) * 0.45
        return Path(roundedRect: rect, cornerRadius: r, style: .continuous)
    }
}

#Preview {
    ZStack {
        SkyBackground()
        PlayerSetupView(game: GameViewModel())
    }
}
