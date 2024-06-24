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

    var contestant: ContestantProtocol

    let accentColor: Color = Color.blue

    var body: some View {
        HStack {
            runningNumber
            Text(contestant.name)
                .font(.largeTitle.weight(.medium))
            Spacer()
            voteCount
        }
        .padding()
        .overlay(
            Capsule(style: .continuous)
                .stroke(accentColor, lineWidth: 5)
        )
    }

    private var runningNumber: some View {
        Text(String(contestant.runningNumber))
            .font(.title3.monospaced().bold())
            .foregroundColor(.primary)
            .padding(.horizontal, 8)
            .overlay(
                Capsule()
                    .fill(accentColor.tertiary)
            )
    }

    private var voteCount: some View {
        Text(String(contestant.revealedVotesCount))
            .contentTransition(.numericText())
            .font(.title.bold())
            .padding(8)
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
    traits: .sizeThatFitsLayout
) {
    var contestant = DemoContestant()
    contestant.revealedVotesCount = 20

    return ContestantPointsCell(contestant: contestant)
        .padding()
}
