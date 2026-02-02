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
                ToolbarItem {
                    if #available(iOS 26.0, *) {
                        Button(role: .confirm) {
                            action()
                        } label: {
                            Label("Confirm", systemImage: "checkmark")
                        }
                    } else {
                        Button {
                            action()
                        } label: {
                            Label("Confirm", systemImage: "checkmark")
                        }
                    }
                }
            }
    }
}

extension View {
    func confirmButton(action: @escaping () -> Void) -> some View {
        modifier(ConfirmButton(action: action))
    }
}
