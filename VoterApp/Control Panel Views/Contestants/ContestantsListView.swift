//
//  ContentView.swift
//  VoterApp
//
//  Created by kacper.czapp on 29/02/2024.
//

import SFSymbols
import SwiftUI
import SwiftData

struct ContestantsListView: View {

    enum SortField: Int, Identifiable {
        case number
        case name

        var id: Int { rawValue }
    }

    @Environment(\.modelContext) private var modelContext

    @Query
    private var contestants: [Contestant]

    @State private var sortDescriptor = SortDescriptor(\Contestant.runningNumber, order: .forward)
    @State private var sortOrder: SortOrder = .forward
    @State private var sortField: SortField = .number

    var body: some View {
        NavigationStack {
            navigationContent
                .toolbar {
                    if !contestants.isEmpty {
                        ToolbarItem {
                            sortMenu
                        }
                    }
                    ToolbarItem {
                        NavigationLink {
                            ContestantDataView()
                        } label: {
                            Label(symbol: .plus) {
                                Text("Add Contestant",
                                     comment: "Button for adding a new contestant")
                            }
                        }
                    }
                }
        }
        .tabItem {
            Label(symbol: .person3SequenceFill) {
                Text("Contestants", comment: "Tab item name")
            }
        }
        .onChange(of: sortOrder) {
            setSortOrder(order: $1)
        }
        .onChange(of: sortField) {
            setSortOrder(field: $1)
        }
    }

    @ViewBuilder
    private var navigationContent: some View {
        if contestants.isEmpty {
            Text("No Contestants",
                 comment: "Title of empty state on list of contestants")
            .padding()
            .multilineTextAlignment(.center)
        } else {
            listView
        }
    }

    @ViewBuilder
    private var listView: some View {
        UserListView(sort: sortDescriptor)
    }

    @ViewBuilder
    private var sortMenu: some View {
        Menu("Sorting", systemImage: SFSymbol.sort.title) {
            Picker(selection: $sortField,
                   label: Text("Sorting value",
                               comment: "Title of the sorting value picker")
            ) {
                Label(symbol: .textformat) {
                    Text("Name", comment: "Sort option by name")
                }
                .tag(SortField.name)

                Label(symbol: .textformat123) {
                    Text("Number", comment: "Sort option by running number")
                }
                .tag(SortField.number)
            }

            Picker(selection: $sortOrder,
                   label: Text("Sorting order", 
                               comment: "Title of the sorting order picker")
            ) {
                Label(symbol: .arrowUp) {
                    Text("Ascending", comment: "Sorting option ascending")
                }
                .tag(SortOrder.forward)

                Label(symbol: .arrowDown) {
                    Text("Descending", comment: "Sorting option descending")
                }
                .tag(SortOrder.reverse)
            }
        }
    }

    private func setSortOrder(field: SortField? = nil,
                              order: SortOrder? = nil) {
        let field = field ?? sortField
        let order = order ?? sortOrder
        print(field, order)

        withAnimation {
            sortDescriptor = switch field {
            case .name:
                    .init(\.name, order: order)
            case .number:
                    .init(\.runningNumber, order: order)
            }
        }
    }
}

#Preview("Populated") {
    TabView {
        ContestantsListView()
            .modelContainer(DataStore.previewContainer)
    }
}

#Preview("Empty") {
    TabView {
        ContestantsListView()
            .modelContainer(DataStore.previewContainer(addContestants: false,
                                                       addCards: false))
    }
}


private struct UserListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query
    private var contestants: [Contestant]

    init(sort: SortDescriptor<Contestant>) {
        _contestants = Query(sort: [sort])
    }

    var body: some View {
        List {
            ForEach(contestants) { contestant in
                NavigationLink {
                    ContestantDataView(contestant)
                        .id(contestant.id)
                } label: {
                    Text("\(contestant.runningNumber): \(contestant.name)")
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}
