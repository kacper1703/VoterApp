//
//  VoterDataView.swift
//  VoterApp
//
//  Created by kacper.czapp on 04/03/2024.
//

import SwiftData
import SwiftUI

struct VoterDataView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query
    private var existingVoters: [Voter]

    private var voter: Voter?

    @State
    var name: String

    @State
    var error: String?

    @State var isCorrect: Bool = false

    init(_ voter: Voter? = nil) {
        self.voter = voter
        if let voter {
            _name = .init(initialValue: voter.name)
        } else {
            _name = .init(initialValue: "")
        }
    }

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                    .autocorrectionDisabled()
            } footer: {
                if let error {
                    Text(error)
                }
            }

            if voter != nil {
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
    }

    private func save() {
        do {
            if let voter {
                voter.name = name
            } else {
                let new = Voter(name: name)
                modelContext.insert(new)
            }
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving: \(error)")
        }
    }

    private func checkData() {
        var errors: [String] = []
        if name.isEmpty {
            errors.append("Name is empty")
        } else if let existing = existingVoters.first(where: { $0.name == name }),
                  existing.id != voter?.id {
            errors.append("Other voter already has this name.")
        }
        self.error = errors.map { "・\($0)\n" }.joined()
        isCorrect = errors.isEmpty
    }

    private func delete() {
        Task {
            guard
                await Alert.showAsync(title: "Are you sure?",
                                      message: "Deleting this voter will also delete all of the associated voting cards.",
                                      buttons: [.continue.styledDestructive, .cancel]) == .continue else {
                return
            }
            await MainActor.run {
                if let voter {
                    for card in voter.voteCards {
                        modelContext.delete(card)
                    }
                    modelContext.delete(voter)
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
    VoterDataView()
}
