//
//  ControlPanelView.swift
//  VoterApp
//
//  Created by kacper.czapp on 04/03/2024.
//

import SwiftUI

struct ControlPanelView: View {
    var body: some View {
        TabView {
            ContestantsListView()
            VotersListView()
            VoteCardsListView()
        }
    }
}

#Preview {
    ControlPanelView()
        .modelContainer(DataStore.previewContainer)
}
