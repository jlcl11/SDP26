//
//  RegisterView.swift
//  SDP26
//
//  Created by José Luis Corral López on 6/2/26.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = RegisterViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 40) {
                    Spacer().frame(height: 20)

                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.badge.plus.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.purple.gradient)

                        Text("Create Account")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Join our manga community")
                            .foregroundStyle(.secondary)
                    }

                    // Form
                    VStack(spacing: 20) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            EmailField(text: $viewModel.email) {
                                viewModel.clearError()
                            }
                            .validationBorder(show: viewModel.emailAlreadyExists, isValid: false)

                            if viewModel.emailAlreadyExists {
                                ValidationMessage(
                                    isValid: false,
                                    validText: "",
                                    invalidText: "User already exists"
                                )
                            }
                        }

                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            PasswordField(
                                label: "Password",
                                placeholder: "Create a password",
                                text: $viewModel.password,
                                isNewPassword: true
                            )

                            if !viewModel.password.isEmpty {
                                PasswordRequirement(
                                    isMet: viewModel.hasMinimumLength,
                                    text: "At least 8 characters"
                                )
                            }
                        }

                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            PasswordField(
                                label: "Confirm Password",
                                placeholder: "Confirm your password",
                                text: $viewModel.confirmPassword,
                                isNewPassword: true
                            )
                            .validationBorder(
                                show: !viewModel.confirmPassword.isEmpty,
                                isValid: viewModel.passwordsMatch
                            )

                            if !viewModel.confirmPassword.isEmpty {
                                ValidationMessage(
                                    isValid: viewModel.passwordsMatch,
                                    validText: "Passwords match",
                                    invalidText: "Passwords don't match"
                                )
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Register Button
                    VStack(spacing: 16) {
                        Button {
                            Task {
                                await viewModel.performRegister()
                                if viewModel.isRegistered { dismiss() }
                            }
                        } label: {
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Create Account")
                            }
                        }
                        .primaryButton(color: .purple, isEnabled: viewModel.isFormValid)
                        .buttonStyle(.plain)
                        .disabled(viewModel.isLoading || !viewModel.isFormValid)

                        // Login Link
                        HStack(spacing: 4) {
                            Text("Already have an account?").foregroundStyle(.secondary)
                            Button("Sign In") { dismiss() }
                                .fontWeight(.semibold)
                                .foregroundStyle(.purple)
                        }
                        .font(.subheadline)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
            }
            .authBackground(colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)])
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.title2)
                    }
                }
            }
        }
    }
}

#Preview {
    RegisterView()
}
