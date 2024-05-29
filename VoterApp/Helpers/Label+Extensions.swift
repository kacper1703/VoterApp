//
//  Label+Extensions.swift
//  VoterApp
//
//  Created by kacper.czapp on 05/03/2024.
//

import SFSymbols
import SwiftUI

extension Label where Title == Text, Icon == Image {
    public init(
        symbol: SFSymbol,
        @ViewBuilder title: () -> Title
    ) {
        self.init(
            title: title,
            icon: {
                Image(symbol: symbol)
            }
        )
    }
}
extension Button where Label == SwiftUI.Label<Text, Image>{
    public init(symbol: SFSymbol,
                @ViewBuilder text: () -> Text,
                action: @escaping () -> Void) {
        self.init {
            action()
        } label: {
            Label {
                text()
            } icon: {
                Image(systemName: symbol.title)
            }
        }
    }
}
