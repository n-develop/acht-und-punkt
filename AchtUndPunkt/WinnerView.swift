//
//  WinnerView.swift
//  AchtUndPunkt
//

import SwiftUI

struct WinnerView: View {
    @ObservedObject var game: GameViewModel
    @State private var trophyScale: CGFloat = 0.2
    @State private var trophyRotation: Double = -25
    @State private var showStandings = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var isIPad: Bool { horizontalSizeClass == .regular }

    var body: some View {
        ZStack {
            if isIPad {
                iPadLayout
            } else {
                iPhoneLayout
            }
        }
        .onAppear {
            if reduceMotion {
                trophyScale = 1.0
                trophyRotation = 0
                showStandings = true
                return
            }
            withAnimation(.interpolatingSpring(stiffness: 80, damping: 8).delay(0.1)) {
                trophyScale = 1.0
                trophyRotation = 0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.8)) {
                showStandings = true
            }
        }
    }

    // MARK: - iPad: side-by-side

    private var iPadLayout: some View {
        HStack(alignment: .top, spacing: 0) {
            // Left column: trophy + winner info + new game button (fixed 320pt)
            VStack(spacing: 0) {
                Spacer()
                trophySection(trophySize: 140, showRays: true)
                Spacer()
                actionButtons
                    .padding(.horizontal, 32)
                    .padding(.bottom, 110)
            }
            .frame(width: 380)
            .opacity(showStandings ? 1 : 0)
            .offset(y: showStandings ? 0 : 20)

            Divider()
                .background(Theme.charcoal.opacity(0.12))
                .padding(.vertical, 40)

            // Right column: standings table (takes remaining width, vertically centered)
            VStack {
                Spacer()
                standingsSection
                    .padding(.horizontal, 24)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .opacity(showStandings ? 1 : 0)
            .offset(y: showStandings ? 0 : 30)
        }
        .animation(.easeOut(duration: 0.5), value: showStandings)
    }

    // MARK: - iPhone: scrolling column

    private var iPhoneLayout: some View {
        ScrollView {
            VStack(spacing: 24) {
                trophySection(trophySize: 130, showRays: true)
                standingsSection
                    .padding(.horizontal, 16)
                    .opacity(showStandings ? 1 : 0)
                    .offset(y: showStandings ? 0 : 30)

                actionButtons
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .opacity(showStandings ? 1 : 0)
            }
            .padding(.top, 28)
            .padding(.bottom, 110)
        }
        .animation(.easeOut(duration: 0.5), value: showStandings)
    }

    // MARK: - Shared subviews

    private func trophySection(trophySize: CGFloat, showRays: Bool) -> some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Theme.sunny.opacity(0.55), .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: trophySize * 1.2
                        )
                    )
                    .frame(width: trophySize * 2.3, height: trophySize * 2.3)
                    .blur(radius: 6)

                if showRays {
                    ForEach(0..<8, id: \.self) { i in
                        Capsule()
                            .fill(Theme.sunny)
                            .frame(width: isIPad ? 8 : 6, height: isIPad ? 32 : 26)
                            .offset(y: -(trophySize * 0.88))
                            .rotationEffect(.degrees(Double(i) * 45 + (showStandings ? 0 : -30)))
                            .opacity(showStandings ? 1 : 0)
                    }
                }

                Image(systemName: "trophy.fill")
                    .font(.system(size: trophySize, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.sunny, Theme.coral],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Theme.coral.opacity(0.4), radius: 16)
                    .scaleEffect(trophyScale)
                    .rotationEffect(.degrees(trophyRotation))
            }
            .accessibilityHidden(true)

            if game.isTie {
                ClayLabel(text: "Unentschieden!", size: isIPad ? 40 : 34, fillColor: .white)
                Text("Es gibt mehrere Sieger:innen.")
                    .font(.system(isIPad ? .title3 : .headline, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Theme.charcoal.opacity(0.25)))
            } else if let winner = game.winner {
                SpeechBubble {
                    Text("Sieger:in")
                        .font(.system(isIPad ? .body : .subheadline, design: .rounded).weight(.heavy))
                        .foregroundStyle(.white)
                        .textCase(.uppercase)
                        .tracking(2)
                }

                ClayLabel(text: winner.name, size: isIPad ? 56 : 46, fillColor: .white, rotation: -2)
                    .padding(.horizontal, 20)
                    .multilineTextAlignment(.center)

                HStack(spacing: 6) {
                    Image(systemName: "star.fill").foregroundStyle(Theme.sunny)
                    Text("\(winner.total) Punkte")
                        .font(.system(isIPad ? .title : .title2, design: .rounded).weight(.heavy))
                        .foregroundStyle(Theme.charcoal)
                    Image(systemName: "star.fill").foregroundStyle(Theme.sunny)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
                .background(Capsule().fill(.white).shadow(color: .black.opacity(0.12), radius: 4, y: 2))
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(winner.total) Punkte")
            }
        }
        .padding(.horizontal, isIPad ? 20 : 0)
    }

    private var standingsSection: some View {
        VStack(spacing: 10) {
            Text("Endstand")
                .font(.system(isIPad ? .title2 : .title2, design: .rounded).weight(.heavy))
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 6)
                .background(Capsule().fill(Theme.charcoal.opacity(0.3)))
                .accessibilityAddTraits(.isHeader)

            ClayCard {
                VStack(spacing: 0) {
                    tableHeader
                    ForEach(Array(game.sortedByTotal.enumerated()), id: \.element.id) { index, player in
                        standingsRow(rank: index + 1, player: player)
                        if index < game.sortedByTotal.count - 1 {
                            Divider().background(Theme.charcoal.opacity(0.10))
                        }
                    }
                }
            }
        }
    }

    private var rankColWidth: CGFloat { isIPad ? 42 : 30 }
    private var roundColWidth: CGFloat { isIPad ? 42 : 30 }
    private var totalColWidth: CGFloat { isIPad ? 58 : 44 }

    private var tableHeader: some View {
        HStack(spacing: 8) {
            Text("#")
                .frame(width: rankColWidth, alignment: .leading)
            Text("Name")
                .frame(maxWidth: .infinity, alignment: .leading)
            ForEach(0..<GameViewModel.totalRounds, id: \.self) { round in
                Text("R\(round + 1)")
                    .frame(width: roundColWidth)
            }
            Text("Σ")
                .frame(width: totalColWidth, alignment: .trailing)
        }
        .font(.system(isIPad ? .body : .caption, design: .rounded).weight(.heavy))
        .foregroundStyle(.white)
        .padding(.horizontal, isIPad ? 22 : 14)
        .padding(.vertical, isIPad ? 16 : 10)
        .background(Theme.grass)
        // Each standings row reads its full context; "R1"/"Σ" would only confuse
        .accessibilityHidden(true)
    }

    private func standingsRow(rank: Int, player: Player) -> some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(rankColor(rank))
                    .frame(width: isIPad ? 38 : 26, height: isIPad ? 38 : 26)
                    .overlay(Circle().stroke(.white, lineWidth: 1.5))
                Text("\(rank)")
                    .font(.system(isIPad ? .body : .caption, design: .rounded).weight(.heavy))
                    .foregroundStyle(Theme.charcoal)
            }
            .frame(width: rankColWidth, alignment: .leading)

            Text(player.name)
                .font(.system(isIPad ? .title3 : .subheadline, design: .rounded).weight(.bold))
                .foregroundStyle(Theme.charcoal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)

            ForEach(0..<GameViewModel.totalRounds, id: \.self) { round in
                Text(player.roundScores[round].map(String.init) ?? "–")
                    .font(.system(isIPad ? .body : .caption, design: .rounded).monospacedDigit().weight(.semibold))
                    .foregroundStyle(Theme.charcoal.opacity(0.75))
                    .frame(width: roundColWidth)
            }

            Text("\(player.total)")
                .font(.system(isIPad ? .title3 : .subheadline, design: .rounded).weight(.black).monospacedDigit())
                .foregroundStyle(Theme.charcoal)
                .frame(width: totalColWidth, alignment: .trailing)
        }
        .padding(.horizontal, isIPad ? 22 : 14)
        .padding(.vertical, isIPad ? 20 : 12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(standingsAccessibilityLabel(rank: rank, player: player))
    }

    private func standingsAccessibilityLabel(rank: Int, player: Player) -> String {
        let rounds = (0..<GameViewModel.totalRounds).map { round in
            "Runde \(round + 1): \(player.roundScores[round].map(String.init) ?? "keine Wertung")"
        }
        return "Platz \(rank): \(player.name), \(rounds.joined(separator: ", ")), Gesamt \(player.total) Punkte"
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                withAnimation { game.restartWithSamePlayers() }
            } label: {
                Label("Nochmal mit gleichen Spielern", systemImage: "arrow.clockwise")
            }
            .buttonStyle(ChunkyButtonStyle(fill: Theme.grass))

            Button {
                withAnimation { game.reset() }
            } label: {
                Label("Neues Spiel", systemImage: "person.2.fill")
            }
            .buttonStyle(ChunkyButtonStyle(fill: Theme.coral))
        }
    }

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return Theme.sunny
        case 2: return Color(white: 0.82)
        case 3: return Theme.coral
        default: return Theme.cream
        }
    }
}

#Preview {
    let game = GameViewModel()
    game.players = [
        Player(name: "Anna"), Player(name: "Ben"),
        Player(name: "Clara"), Player(name: "David")
    ]
    for i in game.players.indices {
        for r in 0..<GameViewModel.totalRounds {
            game.players[i].roundScores[r] = Int.random(in: 0...20)
        }
    }
    game.phase = .finished

    return ZStack {
        SkyBackground()
        WinnerView(game: game)
    }
}
