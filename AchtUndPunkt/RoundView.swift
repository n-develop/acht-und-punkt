//
//  RoundView.swift
//  AchtUndPunkt
//

import SwiftUI

struct RoundView: View {
    @Bindable var game: GameViewModel
    let round: Int

    @State private var scoreInputs: [UUID: String] = [:]
    @FocusState private var focusedPlayer: UUID?

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
        VStack(spacing: 20) {
            header

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Array(game.players.enumerated()), id: \.element.id) { index, player in
                        scoreRow(index: index, player: player)
                    }
                }
                .padding(.horizontal, 20)
            }

            actionButton
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
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
        VStack(spacing: 6) {
            Text("Runde \(round + 1) von \(GameViewModel.totalRounds)")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            ProgressView(value: Double(round + 1), total: Double(GameViewModel.totalRounds))
                .progressViewStyle(.linear)
                .tint(
                    LinearGradient(
                        colors: [.yellow, .orange, .pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(maxWidth: 240)

            Text("Punkte für diese Runde eintragen")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))
                .padding(.top, 4)
        }
        .padding(.top, 32)
    }

    private func scoreRow(index: Int, player: Player) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(playerColor(for: index))
                    .frame(width: 44, height: 44)
                Text(initials(for: player.name))
                    .font(.headline.bold())
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("Gesamt: \(player.total)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer()

            TextField(
                "",
                text: Binding(
                    get: { scoreInputs[player.id] ?? "" },
                    set: { newValue in
                        let filtered = newValue.filter { $0.isNumber || $0 == "-" }
                        scoreInputs[player.id] = filtered
                    }
                ),
                prompt: Text("0").foregroundStyle(.white.opacity(0.4))
            )
            .keyboardType(.numbersAndPunctuation)
            .multilineTextAlignment(.center)
            .font(.title2.weight(.bold))
            .foregroundStyle(.white)
            .frame(width: 80, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.15))
            )
            .focused($focusedPlayer, equals: player.id)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white.opacity(0.10))
        )
    }

    private var actionButton: some View {
        Button {
            commitScores()
            withAnimation {
                game.advanceRound()
            }
        } label: {
            HStack {
                Image(systemName: isLastRound ? "flag.checkered" : "arrow.right.circle.fill")
                Text(isLastRound ? "Endergebnis anzeigen" : "Nächste Runde")
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
            .opacity(allScoresEntered ? 1.0 : 0.4)
        }
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
        let palette: [Color] = [.pink, .orange, .yellow, .green, .cyan, .purple]
        return palette[index % palette.count]
    }

    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        if let first = parts.first?.first {
            if parts.count > 1, let second = parts.last?.first {
                return "\(first)\(second)".uppercased()
            }
            return String(first).uppercased()
        }
        return "?"
    }
}

#Preview {
    let game = GameViewModel()
    game.players = [
        Player(name: "Anna"),
        Player(name: "Ben"),
        Player(name: "Clara")
    ]
    game.phase = .playing(round: 1)
    game.players[0].roundScores[0] = 12
    game.players[1].roundScores[0] = 8
    game.players[2].roundScores[0] = 15

    return ZStack {
        LinearGradient(
            colors: [
                Color(red: 0.10, green: 0.12, blue: 0.30),
                Color(red: 0.25, green: 0.10, blue: 0.45)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        RoundView(game: game, round: 1)
    }
    .preferredColorScheme(.dark)
}
