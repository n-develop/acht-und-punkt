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

    init() {
        self.players = [Player(name: ""), Player(name: "")]
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

    func removePlayer(at index: Int) {
        guard canRemovePlayer, players.indices.contains(index) else { return }
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
