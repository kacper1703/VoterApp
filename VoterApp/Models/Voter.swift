//
//  Voter.swift
//  VoterApp
//
//  Created by kacper.czapp on 01/03/2024.
//

import Foundation
import SwiftData

@Model
final class Voter: Identifiable {
    @Attribute(.unique) let id: UUID
    var name: String

    @Relationship(deleteRule: .cascade,
                  inverse: \VoteCard.voter)
    var voteCards: [VoteCard] = []

    init(
        name: String
    ) {
        self.id = UUID()
        self.name = name
    }
}
