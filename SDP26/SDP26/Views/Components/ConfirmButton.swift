//
//  ConfirmButton.swift
//  SDP26
//
//  Created by José Luis Corral López on 2/2/26.
//

import SwiftUI

fileprivate struct ConfirmButton: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: action)
                }
            }
    }
}

extension View {
    func confirmButton(action: @escaping () -> Void) -> some View {
        modifier(ConfirmButton(action: action))
    }
}
