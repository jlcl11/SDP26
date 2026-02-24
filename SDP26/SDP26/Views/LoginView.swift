//
//  LoginView.swift
//  SDP26
//
//  Created by José Luis Corral López on 31/1/26.
//

import SwiftUI

struct LoginView: View {
    @State private var viewModel = LoginViewModel()
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 40) {
                    Spacer().frame(height: 60)

                    // Logo & Title
                    VStack(spacing: 16) {
                        Image(systemName: "books.vertical.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue.gradient)

                        Text("MangaVault")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Your personal manga collection")
                            .foregroundStyle(.secondary)
                    }

                    // Form
                    VStack(spacing: 20) {
                        EmailField(text: $viewModel.email)
                        PasswordField(
                            label: "Password",
                            placeholder: "Enter your password",
                            text: $viewModel.password
                        )
                    }
                    .padding(.horizontal)

                    // Login Button
                    VStack(spacing: 16) {
                        Button {
                            Task { await viewModel.performLogin() }
                        } label: {
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Sign In")
                            }
                        }
                        .primaryButton(isEnabled: viewModel.isFormValid)
                        .buttonStyle(.plain)
                        .disabled(viewModel.isLoading || !viewModel.isFormValid)

                        // Divider
                        HStack {
                            Rectangle().fill(.secondary.opacity(0.3)).frame(height: 1)
                            Text("or").subtitleStyle()
                            Rectangle().fill(.secondary.opacity(0.3)).frame(height: 1)
                        }

                        // Register Link
                        HStack(spacing: 4) {
                            Text("Don't have an account?").foregroundStyle(.secondary)
                            Button("Sign Up") { showRegister = true }
                                .fontWeight(.semibold)
                                .foregroundStyle(.blue)
                        }
                        .font(.subheadline)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
            }
            .authBackground()
            .sheet(isPresented: $showRegister) {
                RegisterView()
            }
            .task {
                await viewModel.preloadData()
            }
        }
    }
}

#Preview {
    LoginView()
}
