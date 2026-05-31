//
//  RoundView.swift
//  AchtUndPunkt
//

import SwiftUI

struct RoundView: View {
    @ObservedObject var game: GameViewModel
    let round: Int

    @State private var scoreInputs: [UUID: String] = [:]
    @FocusState private var focusedPlayer: UUID?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isIPad: Bool { horizontalSizeClass == .regular }

    private var isLastRound: Bool {
        round == GameViewModel.totalRounds - 1
    }

    private var allScoresEntered: Bool {
        game.players.allSatisfy { player in
            if let text = scoreInputs[player.id], Int(text.trimmingCharacters(in: .whitespaces)) != nil {
                return true
            }
            return false
        }
    }

    var body: some View {
        VStack(spacing: isIPad ? 20 : 16) {
            header

            ScrollView {
                playerList
                    .padding(.horizontal, isIPad ? 32 : 20)
                    .padding(.bottom, 8)
            }

            actionButton
                .padding(.horizontal, isIPad ? 32 : 20)
                .frame(maxWidth: isIPad ? 500 : .infinity)
                .padding(.bottom, 90)
        }
        .onAppear {
            for player in game.players where scoreInputs[player.id] == nil {
                scoreInputs[player.id] = ""
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Fertig") { focusedPlayer = nil }
                    .fontWeight(.semibold)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            SpeechBubble {
                Text("Runde \(round + 1) von \(GameViewModel.totalRounds)")
                    .font(.system(isIPad ? .title : .title2, design: .rounded).weight(.heavy))
                    .foregroundStyle(.white)
            }

            HStack(spacing: isIPad ? 12 : 8) {
                ForEach(0..<GameViewModel.totalRounds, id: \.self) { i in
                    Circle()
                        .fill(i <= round ? Theme.sunny : .white.opacity(0.6))
                        .frame(width: isIPad ? 18 : 14, height: isIPad ? 18 : 14)
                        .overlay(Circle().stroke(Theme.charcoal.opacity(0.25), lineWidth: 1))
                }
            }

            Text("Punkte für diese Runde eintragen")
                .font(.system(isIPad ? .body : .subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(Theme.charcoal.opacity(0.85))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Capsule().fill(.white.opacity(0.85)))
        }
        .padding(.top, isIPad ? 36 : 28)
    }

    @ViewBuilder
    private var playerList: some View {
        if isIPad {
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 14
            ) {
                ForEach(Array(game.players.enumerated()), id: \.element.id) { index, player in
                    scoreRow(index: index, player: player)
                }
            }
        } else {
            VStack(spacing: 12) {
                ForEach(Array(game.players.enumerated()), id: \.element.id) { index, player in
                    scoreRow(index: index, player: player)
                }
            }
        }
    }

    private func scoreRow(index: Int, player: Player) -> some View {
        ClayCard {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(playerColor(for: index))
                        .frame(width: 48, height: 48)
                        .overlay(Circle().stroke(.white, lineWidth: 2))
                        .shadow(color: .black.opacity(0.12), radius: 2, y: 2)
                    Image(systemName: playerSymbol(for: index))
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(player.name)
                        .font(.system(.headline, design: .rounded).weight(.heavy))
                        .foregroundStyle(Theme.charcoal)
                        .lineLimit(1)
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(Theme.sunny)
                        Text("Gesamt: \(player.total)")
                            .font(.system(.caption, design: .rounded).weight(.semibold))
                            .foregroundStyle(Theme.charcoal.opacity(0.7))
                    }
                }

                Spacer()

                ScoreInputField(
                    text: Binding(
                        get: { scoreInputs[player.id] ?? "" },
                        set: { newValue in
                            let filtered = newValue.filter { $0.isNumber || $0 == "-" }
                            scoreInputs[player.id] = filtered
                        }
                    ),
                    focused: $focusedPlayer,
                    id: player.id
                )
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
    }

    private var actionButton: some View {
        Button {
            commitScores()
            withAnimation { game.advanceRound() }
        } label: {
            Label(
                isLastRound ? "Endergebnis anzeigen" : "Nächste Runde",
                systemImage: isLastRound ? "flag.checkered" : "arrow.right.circle.fill"
            )
        }
        .buttonStyle(ChunkyButtonStyle(
            fill: isLastRound ? Theme.coral : Theme.grass,
            disabled: !allScoresEntered
        ))
        .disabled(!allScoresEntered)
    }

    private func commitScores() {
        for index in game.players.indices {
            let id = game.players[index].id
            if let text = scoreInputs[id], let value = Int(text.trimmingCharacters(in: .whitespaces)) {
                game.players[index].roundScores[round] = value
            }
        }
    }

    private func playerColor(for index: Int) -> Color {
        Theme.playerPalette[index % Theme.playerPalette.count]
    }

    private func playerSymbol(for index: Int) -> String {
        Theme.playerSymbols[index % Theme.playerSymbols.count]
    }
}

private struct ScoreInputField: View {
    @Binding var text: String
    var focused: FocusState<UUID?>.Binding
    let id: UUID

    private var displayValue: Int? {
        Int(text.trimmingCharacters(in: .whitespaces))
    }

    private var chipColor: Color {
        guard let v = displayValue else { return Theme.cream }
        if v < 0 { return Theme.claret }
        if v > 0 { return Theme.grass }
        return Theme.charcoal.opacity(0.5)
    }

    var body: some View {
        TextField(
            "",
            text: $text,
            prompt: Text("0").foregroundColor(.white.opacity(0.6))
        )
        .keyboardType(.numbersAndPunctuation)
        .multilineTextAlignment(.center)
        .font(.system(.title2, design: .rounded).weight(.black))
        .foregroundStyle(displayValue == nil ? Theme.charcoal.opacity(0.45) : .white)
        .frame(width: 78, height: 52)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(displayValue == nil ? Theme.cream : chipColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Theme.charcoal.opacity(0.2), lineWidth: 1.5)
                )
                .shadow(color: .black.opacity(0.08), radius: 2, y: 2)
        )
        .focused(focused, equals: id)
    }
}

#Preview {
    let game = GameViewModel()
    game.players = [
        Player(name: "Anna"), Player(name: "Ben"),
        Player(name: "Clara"), Player(name: "David")
    ]
    game.phase = .playing(round: 1)
    game.players[0].roundScores[0] = 12
    game.players[1].roundScores[0] = 8

    return ZStack {
        SkyBackground()
        RoundView(game: game, round: 1)
    }
}
