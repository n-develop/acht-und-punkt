//
//  RoundView.swift
//  AchtUndPunkt
//

import SwiftUI

struct RoundView: View {
    @ObservedObject var game: GameViewModel
    let round: Int

    @State private var scoreInputs: [UUID: String] = [:]
    @State private var achtUndAusPlayer: UUID? = nil
    @State private var selectedPlayer: UUID? = nil
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private let maxDigits = 2

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
        ZStack(alignment: .bottom) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: isIPad ? 20 : 16) {
                        header

                        playerList
                            .padding(.horizontal, isIPad ? 32 : 20)
                            .padding(.bottom, 8)

                        actionButton
                            .padding(.horizontal, isIPad ? 32 : 20)
                            .frame(maxWidth: isIPad ? 500 : .infinity)
                            .padding(.bottom, selectedPlayer == nil ? 90 : 360)
                    }
                }
                .onChange(of: selectedPlayer) { newValue in
                    guard let id = newValue else { return }
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        proxy.scrollTo(id, anchor: .center)
                    }
                }
            }

            if let id = selectedPlayer {
                Color.black.opacity(0.12)
                    .ignoresSafeArea()
                    .onTapGesture { selectPlayer(nil) }
                    .transition(.opacity)
                    // The keypad is modal and has its own close button
                    .accessibilityHidden(true)

                keypad(for: id)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            for player in game.players where scoreInputs[player.id] == nil {
                scoreInputs[player.id] = ""
            }
            if let idx = game.screenshotAchtUndAusIndex, game.players.indices.contains(idx) {
                let player = game.players[idx]
                achtUndAusPlayer = player.id
                scoreInputs[player.id] = "16"
                // Showcase the custom keypad in App Store screenshots
                selectedPlayer = player.id
            }
        }
    }

    @ViewBuilder
    private func keypad(for id: UUID) -> some View {
        if let index = game.players.firstIndex(where: { $0.id == id }) {
            let player = game.players[index]
            ScoreKeypad(
                playerName: player.name,
                playerColor: playerColor(for: index),
                playerSymbol: playerSymbol(for: index),
                currentValue: scoreInputs[id] ?? "",
                isAchtUndAus: achtUndAusPlayer == id,
                isLastPlayer: index == game.players.count - 1,
                onDigit: { appendDigit($0) },
                onDelete: { deleteDigit() },
                onAchtUndAus: { setAchtUndAus() },
                onNext: { advanceSelection() },
                onDismiss: { selectPlayer(nil) }
            )
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            SpeechBubble {
                Text("Runde \(round + 1) von \(GameViewModel.totalRounds)")
                    .font(.system(isIPad ? .title : .title2, design: .rounded).weight(.heavy))
                    .foregroundStyle(.white)
            }
            .accessibilityAddTraits(.isHeader)

            HStack(spacing: isIPad ? 12 : 8) {
                ForEach(0..<GameViewModel.totalRounds, id: \.self) { i in
                    Circle()
                        .fill(i <= round ? Theme.sunny : .white.opacity(0.6))
                        .frame(width: isIPad ? 18 : 14, height: isIPad ? 18 : 14)
                        .overlay(Circle().stroke(Theme.charcoal.opacity(0.25), lineWidth: 1))
                }
            }
            // The speech bubble above already announces "Runde x von y"
            .accessibilityHidden(true)

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
        let isWinner = achtUndAusPlayer == player.id
        return Button {
            selectPlayer(player.id)
        } label: {
            ClayCard(fill: isWinner ? Theme.sunny.opacity(0.18) : .white) {
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

                    ScoreChip(
                        value: scoreInputs[player.id] ?? "",
                        isSelected: selectedPlayer == player.id,
                        isAchtUndAus: isWinner
                    )
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(player.name), Gesamt \(player.total) Punkte")
        .accessibilityValue(accessibilityScoreValue(for: player.id, isWinner: isWinner))
        .accessibilityHint("Öffnet das Tastenfeld zur Punkteeingabe")
        .id(player.id)
    }

    private func accessibilityScoreValue(for id: UUID, isWinner: Bool) -> String {
        guard let text = scoreInputs[id],
              let value = Int(text.trimmingCharacters(in: .whitespaces)) else {
            return "Noch keine Punkte eingetragen"
        }
        let base = "\(value) Punkte diese Runde"
        return isWinner ? "\(base), Acht und aus" : base
    }

    // MARK: - Keypad actions

    private func selectPlayer(_ id: UUID?) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            selectedPlayer = id
        }
    }

    private func appendDigit(_ digit: Int) {
        guard let id = selectedPlayer else { return }
        // Typing replaces an "Acht und aus!" prefill rather than appending to "16"
        if achtUndAusPlayer == id {
            achtUndAusPlayer = nil
            scoreInputs[id] = ""
        }
        var current = scoreInputs[id] ?? ""
        if current == "0" { current = "" }   // avoid a leading zero
        guard current.count < maxDigits else { return }
        current.append(String(digit))
        scoreInputs[id] = current
    }

    private func deleteDigit() {
        guard let id = selectedPlayer else { return }
        if achtUndAusPlayer == id { achtUndAusPlayer = nil }
        var current = scoreInputs[id] ?? ""
        if !current.isEmpty { current.removeLast() }
        scoreInputs[id] = current
    }

    private func setAchtUndAus() {
        guard let id = selectedPlayer else { return }
        // Clear any other player's untouched "16" prefill
        if let prev = achtUndAusPlayer, prev != id, scoreInputs[prev] == "16" {
            scoreInputs[prev] = ""
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
            achtUndAusPlayer = id
            scoreInputs[id] = "16"
        }
    }

    /// Whether a score has already been entered for this round for the player.
    private func hasScore(_ id: UUID) -> Bool {
        guard let text = scoreInputs[id] else { return false }
        return Int(text.trimmingCharacters(in: .whitespaces)) != nil
    }

    /// Move to the next player that still needs a score, wrapping around the
    /// list. If everyone already has a score, dismiss the keypad.
    private func advanceSelection() {
        guard let id = selectedPlayer,
              let index = game.players.firstIndex(where: { $0.id == id }) else { return }
        let count = game.players.count
        for offset in 1...count {
            let candidate = game.players[(index + offset) % count]
            if candidate.id != id && !hasScore(candidate.id) {
                selectPlayer(candidate.id)
                return
            }
        }
        selectPlayer(nil)
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

/// Score display chip on a player tile. The whole tile is tappable; this just
/// reflects the current value and selection state.
private struct ScoreChip: View {
    let value: String
    let isSelected: Bool
    let isAchtUndAus: Bool

    private var displayValue: Int? {
        Int(value.trimmingCharacters(in: .whitespaces))
    }

    private var fillColor: Color {
        if isAchtUndAus { return Theme.coral }
        guard let v = displayValue else { return Theme.cream }
        if v > 0 { return Theme.grass }
        return Theme.charcoal.opacity(0.5)
    }

    var body: some View {
        Text(displayValue == nil ? "0" : value)
            .multilineTextAlignment(.center)
            .font(.system(.title2, design: .rounded).weight(.black))
            .foregroundStyle(displayValue == nil ? Theme.charcoal.opacity(0.35) : .white)
            .frame(width: 78, height: 52)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(fillColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(
                                isSelected ? Theme.charcoal.opacity(0.75) : Theme.charcoal.opacity(0.2),
                                lineWidth: isSelected ? 2.5 : 1.5
                            )
                    )
                    .shadow(color: .black.opacity(0.08), radius: 2, y: 2)
            )
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
