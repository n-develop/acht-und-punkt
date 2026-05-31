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

    var body: some View {
        ZStack {
            ConfettiView()
                .opacity(showStandings ? 1 : 0)
                .animation(.easeIn(duration: 0.5), value: showStandings)

            ScrollView {
                VStack(spacing: 24) {
                    trophySection
                    standingsSection
                        .opacity(showStandings ? 1 : 0)
                        .offset(y: showStandings ? 0 : 30)

                    Button {
                        withAnimation {
                            game.reset()
                        }
                    } label: {
                        Label("Neues Spiel", systemImage: "arrow.counterclockwise")
                    }
                    .buttonStyle(ChunkyButtonStyle(fill: Theme.coral))
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .opacity(showStandings ? 1 : 0)
                }
                .padding(.top, 28)
                .padding(.bottom, 100)
            }
        }
        .onAppear {
            withAnimation(.interpolatingSpring(stiffness: 80, damping: 8).delay(0.1)) {
                trophyScale = 1.0
                trophyRotation = 0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.8)) {
                showStandings = true
            }
        }
    }

    private var trophySection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Theme.sunny.opacity(0.55), .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 160
                        )
                    )
                    .frame(width: 300, height: 300)
                    .blur(radius: 6)

                ForEach(0..<8, id: \.self) { i in
                    Capsule()
                        .fill(Theme.sunny)
                        .frame(width: 6, height: 26)
                        .offset(y: -110)
                        .rotationEffect(.degrees(Double(i) * 45 + (showStandings ? 0 : -30)))
                        .opacity(showStandings ? 1 : 0)
                }

                Image(systemName: "trophy.fill")
                    .font(.system(size: 130, weight: .bold))
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

            if game.isTie {
                ClayLabel(text: "Unentschieden!", size: 34, fillColor: .white)
                Text("Es gibt mehrere Sieger:innen.")
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Theme.charcoal.opacity(0.25)))
            } else if let winner = game.winner {
                SpeechBubble {
                    Text("Sieger:in")
                        .font(.system(.subheadline, design: .rounded).weight(.heavy))
                        .foregroundStyle(.white)
                        .textCase(.uppercase)
                        .tracking(2)
                }

                ClayLabel(text: winner.name, size: 46, fillColor: .white, rotation: -2)
                    .padding(.horizontal, 20)
                    .multilineTextAlignment(.center)

                HStack(spacing: 6) {
                    Image(systemName: "star.fill").foregroundStyle(Theme.sunny)
                    Text("\(winner.total) Punkte")
                        .font(.system(.title2, design: .rounded).weight(.heavy))
                        .foregroundStyle(Theme.charcoal)
                    Image(systemName: "star.fill").foregroundStyle(Theme.sunny)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(.white)
                        .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
                )
            }
        }
    }

    private var standingsSection: some View {
        VStack(spacing: 10) {
            Text("Endstand")
                .font(.system(.title2, design: .rounded).weight(.heavy))
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 6)
                .background(Capsule().fill(Theme.charcoal.opacity(0.3)))

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
            .padding(.horizontal, 20)
        }
    }

    private var tableHeader: some View {
        HStack(spacing: 8) {
            Text("#")
                .frame(width: 28, alignment: .leading)
            Text("Spieler:in")
                .frame(maxWidth: .infinity, alignment: .leading)
            ForEach(0..<GameViewModel.totalRounds, id: \.self) { round in
                Text("R\(round + 1)")
                    .frame(width: 28)
            }
            Text("Σ")
                .frame(width: 40, alignment: .trailing)
        }
        .font(.system(.caption, design: .rounded).weight(.heavy))
        .foregroundStyle(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Theme.grass)
    }

    private func standingsRow(rank: Int, player: Player) -> some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(rankColor(rank))
                    .frame(width: 26, height: 26)
                    .overlay(Circle().stroke(.white, lineWidth: 1.5))
                Text("\(rank)")
                    .font(.system(.caption, design: .rounded).weight(.heavy))
                    .foregroundStyle(Theme.charcoal)
            }
            .frame(width: 28, alignment: .leading)

            Text(player.name)
                .font(.system(.subheadline, design: .rounded).weight(.bold))
                .foregroundStyle(Theme.charcoal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)

            ForEach(0..<GameViewModel.totalRounds, id: \.self) { round in
                Text(player.roundScores[round].map(String.init) ?? "–")
                    .font(.system(.caption, design: .rounded).monospacedDigit().weight(.semibold))
                    .foregroundStyle(Theme.charcoal.opacity(0.75))
                    .frame(width: 28)
            }

            Text("\(player.total)")
                .font(.system(.subheadline, design: .rounded).weight(.black).monospacedDigit())
                .foregroundStyle(Theme.charcoal)
                .frame(width: 40, alignment: .trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
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
        Player(name: "Anna"),
        Player(name: "Ben"),
        Player(name: "Clara"),
        Player(name: "David")
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
