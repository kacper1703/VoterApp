//
//  ExternalView.swift
//  VoterApp
//
//  Created by kacper.czapp on 04/03/2024.
//

import SwiftData
import SwiftUI

struct ExternalView: View {

    @Environment(\.modelContext) private var modelContext

    @Query(
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
                ContestantPointsCell(contestantID: contestant.id)
            }
            .id(contestant.id)
            .padding(8)
        }
    }
}

#Preview {
    ExternalView()
        .modelContainer(DataStore.previewContainer(count: 5))
        .previewLayout(PreviewLayout.fixed(width: 1280, height: 720))
}
