//
//  VoteCardDataView.swift
//  VoterApp
//
//  Created by kacper.czapp on 04/03/2024.
//

import SwiftData
import SwiftUI

struct VoteCardDataView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Contestant.runningNumber, order: .forward)
    private var contestants: [Contestant]

    @Query(sort: \Voter.name, order: .forward)
    private var voters: [Voter]

    @State private var contestantId: Contestant.ID
    @State private var voterId: Voter.ID
    @State private var points: String
    @State private var isRevealed: Bool

    @State private var error: String?
    @State private var isCorrect: Bool = false

    private var card: VoteCard?
    private let isEditingExisting: Bool

    init(_ card: VoteCard) {
        self.card = card
        isEditingExisting = true
        _contestantId = .init(initialValue: card.contestant.id)
        _voterId = .init(initialValue: card.voter.id)
        _points = .init(initialValue: String(card.points))
        _isRevealed = .init(initialValue: card.isRevealed)
    }

    init(newWith contestant: Contestant, voter: Voter) {
        isEditingExisting = false
        _contestantId = .init(initialValue: contestant.id)
        _voterId = .init(initialValue: voter.id)
        _points = .init(initialValue: "")
        _isRevealed = .init(initialValue: false)
    }

    var body: some View {
        Form {
            dynamicSections
            Section {
                TextField("Points", text: $points)
                    .keyboardType(.numberPad)
                    .autocorrectionDisabled()
            }
            Section {
                Toggle(isOn: $isRevealed) {
                    Text("Revealed")
                }
            } footer: {
                if let error {
                    Text(error)
                }
            }

            if card != nil {
                Section {
                    Button(
                        "Delete",
                        role: .destructive,
                        action: delete
                    )
                }
            }
        }
        .listStyle(.insetGrouped)
        .toolbar {
            Button("Save", action: save)
                .disabled(!isCorrect)
        }
        .onChange(of: contestantId, checkData)
        .onChange(of: voterId, checkData)
        .onChange(of: points, checkData)
        .onChange(of: isRevealed, checkData)
    }

    @ViewBuilder
    private var dynamicSections: some View {
        if isEditingExisting {
            displayOnlyData
                .foregroundColor(.secondary)
        } else {
            editorPickers
        }
    }

    @ViewBuilder
    private var displayOnlyData: some View {
        if let contestant = contestants.first(where: { $0.id == contestantId }),
           let voter = voters.first(where: { $0.id == voterId }) {
            Section {
                Text(verbatim: "\(contestant.runningNumber): \(contestant.name)")
            } footer: {
                Text(verbatim: "test")
            }
            Section {
                Text(voter.name)
            } footer: {
                Text(verbatim: "test")
            }
        }
    }

    @ViewBuilder
    private var editorPickers: some View {
        Section {
            Picker("Contestant", selection: $contestantId) {
                ForEach(contestants) {
                    Text(verbatim: "\($0.runningNumber): \($0.name)")
                        .tag($0)
                }
            }
        }
        Section {
            Picker("Voter", selection: $voterId) {
                ForEach(voters) {
                    Text($0.name)
                        .tag($0)
                }
            }
        }
    }

    private func save() {
        do {
            guard let points = Int(self.points),
                  let contestant = contestants.first(where: { $0.id == contestantId }),
                  let voter = voters.first(where: { $0.id == voterId }) else {
                return
            }
            if let card {
                card.contestant = contestant
                card.voter = voter
                card.points = points
                card.isRevealed = isRevealed
            } else {
                let new = VoteCard(voter: voter,
                                   contestant: contestant,
                                   points: points,
                                   isRevealed: isRevealed)
                modelContext.insert(new)
            }
            contestant.recalculateRevealedVotes()

            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving: \(error)")
        }
    }

    private func checkData() {
        var errors: [String] = []
        if !points.isEmpty, Int(self.points) == nil {
            errors.append("Points field is not a number ")
        }
        self.error = errors.map { "・\($0)\n" }.joined()
        isCorrect = errors.isEmpty
    }

    private func delete() {
        if let card {
            modelContext.delete(card)

            if let contestant = contestants.first(where: { $0.id == contestantId }) {
                contestant.recalculateRevealedVotes()
            }

            do {
                try modelContext.save()
                dismiss()
            } catch {
                print("Error deleting: \(error)")
            }
        }
    }
}

//#Preview {
//    let contestant: Contestant = .init(name: "Contestant", runningNumber: 100)
//    let voter = Voter(name: "Voter")
//    let container = DataStore.previewContainer
//    container.mainContext.insert(contestant)
//    container.mainContext.insert(voter)
//
//    return VoteCardDataView(.init(voter: voter, contestant: contestant,
//                               points: 10, isRevealed: false))
//        .modelContainer(container)
//}
