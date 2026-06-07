//
//  Models.swift
//  AchtUndPunkt
//

import SwiftUI
import Combine

struct Player: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var roundScores: [Int?]

    init(name: String, totalRounds: Int = GameViewModel.totalRounds) {
        self.name = name
        self.roundScores = Array(repeating: nil, count: totalRounds)
    }

    var total: Int {
        roundScores.compactMap { $0 }.reduce(0, +)
    }

    func totalThrough(round: Int) -> Int {
        roundScores.prefix(round + 1).compactMap { $0 }.reduce(0, +)
    }
}

enum GamePhase: Equatable {
    case setup
    case playing(round: Int)
    case finished
}

final class GameViewModel: ObservableObject {
    static let totalRounds = 5

    @Published var players: [Player]
    @Published var phase: GamePhase = .setup

    // Set by screenshot mode; RoundView reads this in onAppear to pre-select Acht-und-Aus
    var screenshotAchtUndAusIndex: Int? = nil

    init() {
        let args = ProcessInfo.processInfo.arguments
        if args.contains("--screenshot-playing") {
            self.players = Self.screenshotPlayers(throughRound: 1)
            self.phase = .playing(round: 2)
            self.screenshotAchtUndAusIndex = 0  // Anna
        } else if args.contains("--screenshot-finished") {
            self.players = Self.screenshotPlayers(throughRound: 4)
            self.phase = .finished
        } else {
            self.players = [Player(name: ""), Player(name: "")]
        }
    }

    // Scores matching the existing App Store screenshots: Anna wins with 66 pts
    // R1=12,16  R2=16,9  R3=8,12  R4=14,11  R5=16,13  (Anna, Ben)
    // R1=7,10   R2=12,8  R3=16,11 R4=10,16  R5=9,7    (Clara, David)
    private static let screenshotScores: [[Int]] = [
        [12, 16, 8, 14, 16],  // Anna  → 66
        [16, 9, 12, 11, 13],  // Ben   → 61
        [7, 12, 16, 10, 9],   // Clara → 54
        [10, 8, 11, 16, 7],   // David → 52
    ]
    private static let screenshotNames = ["Anna", "Ben", "Clara", "David"]

    private static func screenshotPlayers(throughRound lastRound: Int) -> [Player] {
        screenshotNames.enumerated().map { i, name in
            var p = Player(name: name)
            for r in 0...lastRound {
                p.roundScores[r] = screenshotScores[i][r]
            }
            return p
        }
    }

    var canAddPlayer: Bool { players.count < 6 }
    var canRemovePlayer: Bool { players.count > 2 }

    var canStartGame: Bool {
        players.allSatisfy { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    func addPlayer() {
        guard canAddPlayer else { return }
        players.append(Player(name: ""))
    }

    func removePlayer(id: UUID) {
        guard canRemovePlayer, let index = players.firstIndex(where: { $0.id == id }) else { return }
        players.remove(at: index)
    }

    func startGame() {
        for index in players.indices {
            players[index].name = players[index].name.trimmingCharacters(in: .whitespaces)
            players[index].roundScores = Array(repeating: nil, count: Self.totalRounds)
        }
        phase = .playing(round: 0)
    }

    func currentRound() -> Int? {
        if case let .playing(round) = phase { return round }
        return nil
    }

    func allScoresEntered(forRound round: Int) -> Bool {
        players.allSatisfy { $0.roundScores[round] != nil }
    }

    func advanceRound() {
        guard case let .playing(round) = phase else { return }
        if round + 1 >= Self.totalRounds {
            phase = .finished
        } else {
            phase = .playing(round: round + 1)
        }
    }

    func reset() {
        players = [Player(name: ""), Player(name: "")]
        phase = .setup
    }

    func restartWithSamePlayers() {
        for index in players.indices {
            players[index].roundScores = Array(repeating: nil, count: Self.totalRounds)
        }
        phase = .playing(round: 0)
    }

    var sortedByTotal: [Player] {
        players.sorted { $0.total > $1.total }
    }

    var winner: Player? {
        sortedByTotal.first
    }

    var isTie: Bool {
        let sorted = sortedByTotal
        guard sorted.count >= 2 else { return false }
        return sorted[0].total == sorted[1].total
    }
}
