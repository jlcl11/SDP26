//
//  ViewModifiers.swift
//  SDP26
//
//  Created by José Luis Corral López on 4/2/26.
//

import SwiftUI

// MARK: - Text Styles

extension View {
    func scoreStyle() -> some View {
        self.font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(.yellow)
    }

    func secondaryText() -> some View {
        self.font(.caption)
            .foregroundStyle(.secondary)
    }

    func subtitleStyle() -> some View {
        self.font(.subheadline)
            .foregroundStyle(.secondary)
    }

    func sectionTitle() -> some View {
        self.font(.headline)
    }

    func rowTitle() -> some View {
        self.font(.subheadline)
            .fontWeight(.medium)
            .lineLimit(2)
    }

    func cardTitle() -> some View {
        self.font(.caption)
            .fontWeight(.medium)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }
}

// MARK: - Badge & Tag Styles

extension View {
    func badge(_ color: Color) -> some View {
        self.font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color, in: Capsule())
    }

    func tagStyle() -> some View {
        self.font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.secondary.opacity(0.15), in: Capsule())
    }
}

// MARK: - Card & Container Styles

extension View {
    func card() -> some View {
        self.padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    func sectionHeader(_ title: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).sectionTitle()
            self
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Avatar

extension View {
    func avatar(size: CGFloat = 32) -> some View {
        self.font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(.blue.gradient, in: Circle())
    }

    func largeAvatar(size: CGFloat = 80) -> some View {
        self.font(.title)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(.blue.gradient, in: Circle())
    }
}

// MARK: - Auth Form Styles

extension View {
    func fieldLabel() -> some View {
        self.font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(.secondary)
    }

    func fieldIcon() -> some View {
        self.foregroundStyle(.secondary)
            .frame(width: 20)
    }

    func inputField() -> some View {
        self.padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    func authBackground(colors: [Color] = [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]) -> some View {
        self.background {
            LinearGradient(
                colors: colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }

    func primaryButton(color: Color = .blue, isEnabled: Bool = true) -> some View {
        self.frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(color.gradient, in: RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(.white)
            .fontWeight(.semibold)
            .contentShape(Rectangle())
            .opacity(isEnabled ? 1 : 0.6)
    }
}

// MARK: - Previews

#Preview("Text Styles") {
    VStack(alignment: .leading, spacing: 16) {
        Label("9.43", systemImage: "star.fill").scoreStyle()
        Text("Secondary caption").secondaryText()
        Text("Subtitle text").subtitleStyle()
        Text("Section Title").sectionTitle()
    }
    .padding()
}

#Preview("Badge & Tag") {
    VStack(spacing: 16) {
        Text("Publishing").badge(.green)
        Text("Completed").badge(.blue)
        Text("Action").tagStyle()
    }
    .padding()
}

#Preview("Card & Avatar") {
    VStack(spacing: 16) {
        Text("Card content").card()
        Text("K").avatar()
        Text("Content here")
            .sectionHeader("Section Title")
    }
    .padding()
}
