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
                            Text("Email").fieldLabel()

                            HStack(spacing: 12) {
                                Image(systemName: "envelope.fill").fieldIcon()
                                TextField("Enter your email", text: $viewModel.email)
                                    .textContentType(.emailAddress)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                            }
                            .inputField()
                        }

                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password").fieldLabel()

                            HStack(spacing: 12) {
                                Image(systemName: "lock.fill").fieldIcon()
                                SecureField("Create a password", text: $viewModel.password)
                                    .textContentType(.newPassword)
                            }
                            .inputField()

                            if !viewModel.password.isEmpty {
                                HStack(spacing: 4) {
                                    Image(systemName: viewModel.hasMinimumLength ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(viewModel.hasMinimumLength ? .green : .secondary)
                                    Text("At least 8 characters")
                                }
                                .secondaryText()
                            }
                        }

                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password").fieldLabel()

                            HStack(spacing: 12) {
                                Image(systemName: "lock.fill").fieldIcon()
                                SecureField("Confirm your password", text: $viewModel.confirmPassword)
                                    .textContentType(.newPassword)
                            }
                            .inputField()
                            .overlay {
                                if !viewModel.confirmPassword.isEmpty {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(viewModel.passwordsMatch ? .green : .red, lineWidth: 1)
                                }
                            }

                            if !viewModel.confirmPassword.isEmpty {
                                HStack(spacing: 4) {
                                    Image(systemName: viewModel.passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    Text(viewModel.passwordsMatch ? "Passwords match" : "Passwords don't match")
                                }
                                .font(.caption)
                                .foregroundStyle(viewModel.passwordsMatch ? .green : .red)
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
