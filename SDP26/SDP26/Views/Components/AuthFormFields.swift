//
//  AuthFormFields.swift
//  SDP26
//
//  Reusable authentication form field components.
//

import SwiftUI

// MARK: - Base Text Field

struct AuthTextField: View {
    let label: String
    let placeholder: String
    let icon: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).fieldLabel()

            HStack(spacing: 12) {
                Image(systemName: icon).fieldIcon()
                TextField(placeholder, text: $text)
            }
            .inputField()
        }
    }
}

// MARK: - Base Secure Field

struct AuthSecureField: View {
    let label: String
    let placeholder: String
    let icon: String
    @Binding var text: String
    var isNewPassword: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).fieldLabel()

            HStack(spacing: 12) {
                Image(systemName: icon).fieldIcon()
                SecureField(placeholder, text: $text)
                    .textContentType(isNewPassword ? .newPassword : .password)
            }
            .inputField()
        }
    }
}

// MARK: - Email Field

struct EmailField: View {
    @Binding var text: String
    var onChange: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Email").fieldLabel()

            HStack(spacing: 12) {
                Image(systemName: "envelope.fill").fieldIcon()
                TextField("Enter your email", text: $text)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .onChange(of: text) {
                        onChange?()
                    }
            }
            .inputField()
        }
    }
}

// MARK: - Password Field

struct PasswordField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isNewPassword: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).fieldLabel()

            HStack(spacing: 12) {
                Image(systemName: "lock.fill").fieldIcon()
                SecureField(placeholder, text: $text)
                    .textContentType(isNewPassword ? .newPassword : .password)
            }
            .inputField()
        }
    }
}

// MARK: - Validation Message

struct ValidationMessage: View {
    let isValid: Bool
    let validText: String
    let invalidText: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
            Text(isValid ? validText : invalidText)
        }
        .font(.caption)
        .foregroundStyle(isValid ? .green : .red)
    }
}

// MARK: - Password Requirement

struct PasswordRequirement: View {
    let isMet: Bool
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isMet ? .green : .secondary)
            Text(text)
        }
        .secondaryText()
    }
}

// MARK: - Field with Validation Border

struct ValidatedFieldModifier: ViewModifier {
    let showValidation: Bool
    let isValid: Bool

    func body(content: Content) -> some View {
        content
            .overlay {
                if showValidation {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isValid ? .green : .red, lineWidth: 1)
                }
            }
    }
}

extension View {
    func validationBorder(show: Bool, isValid: Bool) -> some View {
        modifier(ValidatedFieldModifier(showValidation: show, isValid: isValid))
    }
}

#Preview("Email Field") {
    VStack {
        EmailField(text: .constant("test@example.com"))
        EmailField(text: .constant(""))
    }
    .padding()
}

#Preview("Password Fields") {
    VStack(spacing: 20) {
        PasswordField(label: "Password", placeholder: "Enter password", text: .constant(""))
        PasswordField(label: "New Password", placeholder: "Create password", text: .constant(""), isNewPassword: true)
    }
    .padding()
}

#Preview("Validation") {
    VStack(spacing: 16) {
        ValidationMessage(isValid: true, validText: "Passwords match", invalidText: "Passwords don't match")
        ValidationMessage(isValid: false, validText: "Passwords match", invalidText: "Passwords don't match")
        PasswordRequirement(isMet: true, text: "At least 8 characters")
        PasswordRequirement(isMet: false, text: "At least 8 characters")
    }
    .padding()
}
