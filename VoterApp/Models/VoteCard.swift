//
//  VoteCard.swift
//  VoterApp
//
//  Created by kacper.czapp on 01/03/2024.
//

import Foundation
import SwiftData

@Model
final class VoteCard: Identifiable {
    @Attribute(.unique) let id: UUID = UUID()

    let creationDate: Date

    var voter: Voter
    var contestant: Contestant
    
    var points: Int
    var isRevealed: Bool

    internal init(
        creationDate: Date = .now,
        voter: Voter,
        contestant: Contestant,
        points: Int,
        isRevealed: Bool
    ) {
        self.creationDate = creationDate
        self.voter = voter
        self.contestant = contestant
        self.points = points
        self.isRevealed = isRevealed
    }

    func setCardRevealed(_ isRevealed: Bool) {
        self.isRevealed = isRevealed
        contestant.recalculateRevealedVotes()
    }
}
