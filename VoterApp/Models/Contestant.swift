//
//  Contestant.swift
//  VoterApp
//
//  Created by kacper.czapp on 01/03/2024.
//

import Foundation
import SwiftData

@Model
final class Contestant: Identifiable {
    @Attribute(.unique) 
    let id: UUID

    var name: String
    
    @Attribute(.unique)
    var runningNumber: Int

    @Relationship(deleteRule: .cascade,
                  inverse: \VoteCard.contestant)
    private (set) var voteCards: [VoteCard] = []

    var revealedVotesCount: Int = 0

    var lastModified: Date = Date.now

    init(
        name: String,
        runningNumber: Int
    ) {
        self.id = UUID()
        self.name = name
        self.runningNumber = runningNumber
        lastModified = .now
    }

    func update<T>(keyPath: ReferenceWritableKeyPath<Contestant, T>, to value: T) {
        self[keyPath: keyPath] = value
        lastModified = .now
    }

    func recalculateRevealedVotes() {
        let newCount = voteCards
            .filter { $0.contestant == self && $0.isRevealed }
            .reduce(into: 0) { partialResult, card in
                partialResult += card.points
            }
        update(keyPath: \.revealedVotesCount, to: newCount)
    }
}
