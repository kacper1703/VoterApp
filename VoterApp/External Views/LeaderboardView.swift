//
//  LeaderboardView.swift
//  VoterApp
//
//  Created by kacper.czapp on 04/03/2024.
//

import SwiftData
import SwiftUI

struct LeaderboardView: View {

    @Environment(\.modelContext) private var modelContext

    @Query(
        filter: #Predicate<Contestant> {
            $0.revealedVotesCount > 0
        },
        sort: [
            SortDescriptor(\Contestant.revealedVotesCount, order: .reverse),
            SortDescriptor(\Contestant.runningNumber)
        ]
    )
    private var contestants: [Contestant]

    var body: some View {
        VStack {
            ViewThatFits {
                LazyVGrid(columns: [.init()]) {
                    content
                }
                LazyVGrid(columns: [.init(), .init()]) {
                    content
                }
                LazyVGrid(columns: [.init(), .init(), .init()]) {
                    content
                }
            }
            Spacer()
        }
        .ignoresSafeArea()
        .animation(.snappy(), value: contestants)
    }

    @ViewBuilder
    private var content: some View {
        ForEach(contestants) { contestant in
            GridRow {
                ContestantPointsCell(contestant: contestant)
            }
            .id(contestant.id)
            .padding(8)
        }
    }
}

#Preview(traits: .fixedLayout(width: 1280, height: 720)) {
    LeaderboardView()
        .modelContainer(DataStore.previewContainer(count: 10, revealAll: true))
}
