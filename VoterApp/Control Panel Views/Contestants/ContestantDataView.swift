//
//  ContestantDataView.swift
//  VoterApp
//
//  Created by kacper.czapp on 01/03/2024.
//

import SwiftData
import SwiftUI

struct ContestantDataView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query
    private var existingContestants: [Contestant]

    private var contestant: Contestant?

    @State
    var name: String

    @State
    var runningNumber: String

    @State
    var error: String?

    @State var isCorrect: Bool = false

    init(_ contestant: Contestant? = nil) {
        self.contestant = contestant
        if let contestant {
            _name = .init(initialValue: contestant.name)
            _runningNumber = .init(initialValue: String(contestant.runningNumber))
        } else {
            _name = .init(initialValue: "")
            _runningNumber = .init(initialValue: "")
        }
    }

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                    .autocorrectionDisabled()
                TextField("Running number", text: $runningNumber)
                    .keyboardType(.numberPad)
                    .autocorrectionDisabled()
            } footer: {
                if let error {
                    Text(error)
                }
            }
            if contestant != nil {
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
        .onChange(of: name, checkData)
        .onChange(of: runningNumber, checkData)
    }

    private func save() {
        do {
            if let number = Int(runningNumber) {
                if let contestant {
                    contestant.update(keyPath: \.name, to: name)
                    contestant.update(keyPath: \.runningNumber, to: number)
                } else {
                    let new = Contestant(name: name,
                                         runningNumber: number)
                    modelContext.insert(new)
                }
                try modelContext.save()
                dismiss()
            }
        } catch {
            print("Error saving: \(error)")
        }
    }

    private func checkData() {
        var errors: [String] = []

        if !runningNumber.isEmpty {
            if let number = Int(runningNumber) {
                if let existingContestant = existingContestants.first(where: { $0.runningNumber == number }),
                    existingContestant.id != contestant?.id {
                    errors.append("\(existingContestant.name) already has this running number.")
                }
            } else {
                errors.append("Running number field is not a number")
            }
        }
        if name.isEmpty {
            errors.append("Name is empty")
        }
        self.error = errors.map { "・\($0)\n" }.joined()
        isCorrect = errors.isEmpty
    }

    private func delete() {
        Task {
            guard
                await Alert.showAsync(title: "Are you sure?",
                                      message: "Deleting this contestant will also delete all of the associated voting cards.",
                                      buttons: [.continue.styledDestructive, .cancel]) == .continue else {
                return
            }
            await MainActor.run {
                if let contestant {
                    for card in contestant.voteCards {
                        modelContext.delete(card)
                    }
                    modelContext.delete(contestant)
                    do {
                        try modelContext.save()
                        dismiss()
                    } catch {
                        print("Error deleting: \(error)")
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ContestantDataView()
            .modelContainer(DataStore.previewContainer)
    }
}
