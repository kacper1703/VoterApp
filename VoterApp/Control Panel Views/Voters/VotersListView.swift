//
//  VotersListView.swift
//  VoterApp
//
//  Created by kacper.czapp on 04/03/2024.
//

import SFSymbols
import SwiftData
import SwiftUI

struct VotersListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Voter.name, order: .forward)
    private var voters: [Voter]

    var body: some View {
        NavigationStack {
            navigationContent
                .toolbar {
                    ToolbarItem {
                        NavigationLink {
                            VoterDataView()
                        } label: {
                            Label(symbol: .plus) {
                                Text("Add Voter",
                                     comment: "Button for adding a new voter")
                            }
                        }
                    }
                }
        }
        .tabItem {
            Label(symbol: .pencilAndListClipboard) {
                Text("Voters",
                     comment: "Tab item name")
            }
        }
    }

    @ViewBuilder
    private var navigationContent: some View {
        if voters.isEmpty {
            Text("No Voters",
                 comment: "Title of empty state on list of voters")
            .padding()
            .multilineTextAlignment(.center)
        } else {
            listView
        }
    }

    @ViewBuilder
    private var listView: some View {
        List {
            ForEach(voters) { voter in
                NavigationLink {
                    VoterDataView(voter)
                        .id(voter.id)
                } label: {
                    Text("\(voter.name)")
                }
            }
        }
    }
}

#Preview("Populated") {
    TabView {
        VotersListView()
            .modelContainer(DataStore.previewContainer)
    }
}

#Preview("Empty") {
    TabView {
        VotersListView()
            .modelContainer(DataStore.previewContainer(addVoters: false,
                                                       addCards: false))
    }
}
