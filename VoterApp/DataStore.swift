//
//  DataStore.swift
//  VoterApp
//
//  Created by kacper.czapp on 04/03/2024.
//

import SwiftData

final class DataStore {
    static let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Voter.self,
            Contestant.self,
            VoteCard.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @MainActor
    static let previewContainer: ModelContainer = previewContainer()

    @MainActor
    static func previewContainer(
        addContestants: Bool = true,
        addVoters: Bool = true,
        addCards: Bool = true,
        count: Int = 5
    ) -> ModelContainer {
        do {
            let schema = Schema([
                Voter.self,
                Contestant.self,
                VoteCard.self
            ])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: schema, configurations: config)

            let names = [
                "John", "Jane", "Andy", "Marie Antoine The Third", "Bo", "Greg", "Frank", "Zoe", "Barbara", "Archie"
            ]
            let shuffledNames = [String](names.reversed())

            for i in 1...count {
                let contestant = Contestant(name: "\(names[i % names.count]) \(i)", runningNumber: i)
                let voter = Voter(name: "\(shuffledNames[i % names.count]) \(i)")
                let voteCard = VoteCard(voter: voter,
                                        contestant: contestant,
                                        points: .random(in: 0...100),
                                        isRevealed: .random())

                if addContestants {
                    container.mainContext.insert(contestant)
                }
                if addVoters {
                    container.mainContext.insert(voter)
                }
                if addCards {
                    assert(addContestants && addVoters, "Cannot add cards if no contestants and voters are added")
                    container.mainContext.insert(voteCard)
                    contestant.revealedVotesCount = if voteCard.isRevealed {
                        voteCard.points
                    } else {
                        0
                    }
                }
            }
            return container
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }
}
