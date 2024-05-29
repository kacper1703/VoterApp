//
//  VoteCardsListView.swift
//  VoterApp
//
//  Created by kacper.czapp on 04/03/2024.
//

import SFSymbols
import SwiftData
import SwiftUI

struct VoteCardsListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(
        filter: #Predicate<VoteCard> {
            $0.isRevealed == false
        },
        sort: \VoteCard.creationDate,
        order: .forward
    )
    private var hiddenCards: [VoteCard]

    @Query(
        filter: #Predicate<VoteCard> {
            $0.isRevealed
        },
        sort: \VoteCard.creationDate,
        order: .forward
    )
    private var revealedCards: [VoteCard]

    @Query(sort: \Contestant.runningNumber, order: .forward)
    private var contestants: [Contestant]

    @Query(sort: \Voter.name, order: .forward)
    private var voters: [Voter]

    var body: some View {
        NavigationStack {
            navigationContent
                .toolbar {
                    toolbar
                }
        }
        .tabItem {
            Label(symbol: .listBulletClipboardFill) {
                Text("Vote Cards",
                     comment: "Tab item name")
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem {
            revealMenu
        }

        if let contestant = contestants.first, let voter = voters.first {
            ToolbarItem {
                NavigationLink {
                    VoteCardDataView(newWith: contestant, voter: voter)
                } label: {
                    Label(symbol: .plus) {
                        Text("Add Card",
                             comment: "Button for adding a new card")
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var revealMenu: some View {
        Menu {
            Button(symbol: .eyeFill) {
                Text("Reveal all",
                     comment: "Title of a button that reveals all cards")
            } action: {
                setAllCards(revealed: true)
            }
            Button(symbol: .eyeSlashFill) {
                Text("Hide all",
                     comment: "Title of a button that hides all cards")
            } action: {
                setAllCards(revealed: false)
            }
        } label: {
            Label(symbol: .eyeCircle) {
                Text("Reveal/hide all cards menu",
                     comment: "Title of the menu that will show or hide all cards at once")
            }
        }
    }

    @ViewBuilder
    private var navigationContent: some View {
        if contestants.isEmpty || voters.isEmpty {
            Text("Not possible to create vote cards. Add at least one contestant and one voter to continue.",
                 comment: "Title of empty state on vote cards list")
            .padding()
            .multilineTextAlignment(.center)
        } else if hiddenCards.isEmpty && revealedCards.isEmpty {
            Text("No vote cards.",
                 comment: "Title of empty state on vote cards list")
            .padding()
            .multilineTextAlignment(.center)
        } else {
            listView
        }
    }

    @ViewBuilder
    private var listView: some View {
        List {
            Section("Revealed cards") {
                section(with: revealedCards)
            }
            Section("Hidden cards") {
                section(with: hiddenCards)
            }
        }
        .animation(.default, value: revealedCards)
        .animation(.default, value: hiddenCards)
    }

    @ViewBuilder
    private func section(with cards: [VoteCard]) -> some View {
        ForEach(cards) { card in
            NavigationLink {
                VoteCardDataView(card)
                    .id(card.id)
            } label: {
                Text(
                    "\(card.points) pts for \(card.contestant.name) from \(card.voter.name)"
                )
            }
        }
    }

    private func setAllCards(revealed: Bool) {
        if revealed {
            for card in hiddenCards {
                card.setCardRevealed(true)
            }
        } else {
            for card in revealedCards {
                card.setCardRevealed(false)
            }
        }
        do {
            try modelContext.save()
        } catch {
            print("Error saving: \(error)")
        }
    }
}

#Preview("Populated") {
    TabView {
        VoteCardsListView()
            .modelContainer(DataStore.previewContainer)
    }
}

#Preview("Empty - no contestants") {
    TabView {
        VoteCardsListView()
            .modelContainer(DataStore.previewContainer(addContestants: false, 
                                                       addCards: false))
    }
}

#Preview("Empty") {
    TabView {
        VoteCardsListView()
            .modelContainer(DataStore.previewContainer(addCards: false))
    }
}
