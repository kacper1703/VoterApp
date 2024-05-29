//
//  ContestantPointsCell.swift
//  VoterApp
//
//  Created by kacper.czapp on 06/03/2024.
//

import SwiftData
import SwiftUI

protocol ContestantProtocol: Observable {
    var name: String { get }
    var runningNumber: Int { get }
    var revealedVotesCount: Int { get }
}

extension Contestant: ContestantProtocol { }

struct ContestantPointsCell: View {

    @Environment(\.modelContext) private var modelContext

    @Query
    private var contestants: [Contestant]

    init(contestantID: Contestant.ID) {
        _contestants = .init(filter: #Predicate<Contestant> {
            $0.id == contestantID
        })
    }

    init() {
        _contestants = .init()
    }

    let accentColor: Color = Color.blue

    var body: some View {
        if let contestant = contestants.first {
            HStack {
                runningNumber(contestant)
                Text(contestant.name)
                    .font(.largeTitle.weight(.medium))
                Spacer()
                voteCount(contestant)
            }
            .padding()
            .overlay(
                Capsule(style: .continuous)
                    .stroke(accentColor, lineWidth: 5)
            )
            .opacity(contestant.revealedVotesCount == 0 ? 0.6 : 1)
        }
    }

    @ViewBuilder
    private func runningNumber(_ contestant: Contestant) -> some View {
        Text(String(contestant.runningNumber))
            .font(.title2.monospaced().bold())
            .foregroundColor(.primary)
            .padding(.horizontal, 8)
            .overlay(
                Capsule()
                    .fill(accentColor.tertiary)
            )
    }

    @ViewBuilder
    private func voteCount(_ contestant: Contestant) -> some View {
        Group {
            if !contestant.voteCards.isEmpty && contestant.revealedVotesCount == 0 {
                Text(verbatim: "?")
            } else {
                Text(String(contestant.revealedVotesCount))
            }
        }
        .font(.title2.monospaced().bold())
        .padding(.horizontal, 8)
        .overlay(
            Capsule()
                .fill(accentColor.tertiary)
        )
    }
}

private struct DemoContestant: ContestantProtocol {
    var name: String = "Very Long Name"
    var runningNumber: Int = 1
    var revealedVotesCount: Int = 0
}

#Preview(
    "With votes",
    traits: .sizeThatFitsLayout
) {
    ContestantPointsCell()
        .modelContainer(DataStore.previewContainer)
        .padding()
}

#Preview(
    "No Votes",
    traits: .sizeThatFitsLayout
) {
    ContestantPointsCell()
        .modelContainer(DataStore.previewContainer)
        .padding()
}
