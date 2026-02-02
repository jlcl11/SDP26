//
//  MultiSelectMenu.swift
//  SDP26
//
//  Created by José Luis Corral López on 2/2/26.
//

import SwiftUI

struct MultiSelectMenu: View {
    let title: String
    let options: [String]
    @Binding var selected: Set<String>

    private var displayText: String {
        selected.isEmpty ? "Select \(title.lowercased())" : selected.joined(separator: ", ")
    }

    var body: some View {
        Section(title) {
            Menu {
                ForEach(options, id: \.self) { option in
                    Button {
                        if selected.contains(option) {
                            selected.remove(option)
                        } else {
                            selected.insert(option)
                        }
                    } label: {
                        HStack {
                            Text(option)
                            if selected.contains(option) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(displayText)
                        .foregroundStyle(selected.isEmpty ? .secondary : .primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                }
            }
        }
    }
}
