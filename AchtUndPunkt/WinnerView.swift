//
//  WinnerView.swift
//  AchtUndPunkt
//

import SwiftUI

struct WinnerView: View {
    @Bindable var game: GameViewModel
    @State private var trophyScale: CGFloat = 0.2
    @State private var trophyRotation: Double = -25
    @State private var showStandings = false

    var body: some View {
        ZStack {
            ConfettiView()
                .opacity(showStandings ? 1 : 0)
                .animation(.easeIn(duration: 0.5), value: showStandings)

            ScrollView {
                VStack(spacing: 28) {
                    trophySection
                    standingsSection
                        .opacity(showStandings ? 1 : 0)
                        .offset(y: showStandings ? 0 : 30)

                    Button {
                        withAnimation {
                            game.reset()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Neues Spiel")
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
                    }
                    .opacity(showStandings ? 1 : 0)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                .padding(.vertical, 40)
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
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.yellow.opacity(0.5), .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 140
                        )
                    )
                    .frame(width: 280, height: 280)
                    .blur(radius: 8)

                Image(systemName: "trophy.fill")
                    .font(.system(size: 140, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .orange.opacity(0.6), radius: 20)
                    .scaleEffect(trophyScale)
                    .rotationEffect(.degrees(trophyRotation))
            }

            if game.isTie {
                Text("Unentschieden!")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text("Es gibt mehrere Sieger.")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.8))
            } else if let winner = game.winner {
                Text("Sieger:in")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.8))
                    .textCase(.uppercase)
                    .tracking(2)

                Text(winner.name)
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Text("\(winner.total) Punkte")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
            }
        }
    }

    private var standingsSection: some View {
        VStack(spacing: 12) {
            Text("Endstand")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .padding(.bottom, 4)

            VStack(spacing: 0) {
                tableHeader
                ForEach(Array(game.sortedByTotal.enumerated()), id: \.element.id) { index, player in
                    standingsRow(rank: index + 1, player: player)
                    if index < game.sortedByTotal.count - 1 {
                        Divider().background(.white.opacity(0.15))
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.10))
            )
            .padding(.horizontal, 20)
        }
    }

    private var tableHeader: some View {
        HStack(spacing: 8) {
            Text("#")
                .frame(width: 28, alignment: .leading)
            Text("Spieler")
                .frame(maxWidth: .infinity, alignment: .leading)
            ForEach(0..<GameViewModel.totalRounds, id: \.self) { round in
                Text("R\(round + 1)")
                    .frame(width: 28)
            }
            Text("Σ")
                .frame(width: 40, alignment: .trailing)
                .bold()
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.white.opacity(0.7))
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.white.opacity(0.08))
    }

    private func standingsRow(rank: Int, player: Player) -> some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(rankColor(rank))
                    .frame(width: 24, height: 24)
                Text("\(rank)")
                    .font(.caption.bold())
                    .foregroundStyle(.black)
            }
            .frame(width: 28, alignment: .leading)

            Text(player.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)

            ForEach(0..<GameViewModel.totalRounds, id: \.self) { round in
                Text(player.roundScores[round].map(String.init) ?? "–")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.white.opacity(0.85))
                    .frame(width: 28)
            }

            Text("\(player.total)")
                .font(.subheadline.weight(.bold).monospacedDigit())
                .foregroundStyle(.white)
                .frame(width: 40, alignment: .trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return Color(white: 0.8)
        case 3: return .orange
        default: return .white.opacity(0.5)
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
        LinearGradient(
            colors: [
                Color(red: 0.10, green: 0.12, blue: 0.30),
                Color(red: 0.25, green: 0.10, blue: 0.45)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        WinnerView(game: game)
    }
    .preferredColorScheme(.dark)
}
