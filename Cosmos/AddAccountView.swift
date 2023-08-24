//
//  AddAccountView.swift
//  Cosmos
//
//  Created by Bosco Ho on 2023-08-24.
//

import SwiftUI

enum UserIDRetrievalError: Error {
    case couldNotFetchUserInformation
}

struct AddAccountView: View {
    
    private enum ViewState {
        case initial
        case loading
        case success, error
    }
    
    @Environment(\.dismiss) var dismiss
    
    @State private var viewState: ViewState = .initial
    
    @State private var instance = ""
    @State private var username = ""
    @State private var password = ""
    @State private var twoFactorCode = ""
        
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Instance")) {
                    TextField(text: $instance, prompt: Text("e.g. lemmy.ml")) {
                        Text("Instance")
                    }
                }
                
                Section(header: Text("Credentials")) {
                    TextField(text: $username, prompt: Text("Username (Required)")) {
                        Text("Username")
                    }
                    SecureField(text: $password, prompt: Text("Password (Required)")) {
                        Text("Password")
                    }
                }
                
                Section {
                    GridRow {
                        // Maybe Replace this with the multi-textbox thing
                        // at some point
                        Text("Verification Code")
                            .foregroundColor(.secondary)
                        SecureField("Code", text: $twoFactorCode, prompt: Text("000000"))
//                            .focused($focusedField, equals: .onetimecode)
                            .textContentType(.oneTimeCode)
                            .submitLabel(.go)
//                            .onAppear {
//                                focusedField = .onetimecode
//                            }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Add Identity")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .safeAreaInset(edge: .top) {
                statusView
            }
            .safeAreaInset(edge: .bottom) {
                Button("Authenticate") {
                    Task {
                        do {
                            try await authenticate()
                        } catch {
                            print(error)
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    @ViewBuilder
    private var statusView: some View {
        switch viewState {
        case .initial:
            Image(systemName: "network")
        case .loading:
            ProgressView()
        case .success:
            Image(systemName: "checkmark.circle.fill")
        case .error:
            Image(systemName: "exclamationmark.triangle.fill")
        }

    }
    
    private func authenticate() async throws {
        guard let instanceURL = try await URL(lemmyInstance: instance) else {
            print("failed to sanitize: \(instance)")
            return
        }
        
        let login = LoginRequest(
            instanceURL: instanceURL,
            username: username,
            password: password,
            totpToken: twoFactorCode.isEmpty ? nil : twoFactorCode)
        
        let response = try await APIClient().perform(request: login)
        
        let newAccount = SavedAccount(
            id: try await getUserID(authToken: response.jwt, instanceURL: instanceURL),
            instanceLink: instanceURL,
            accessToken: response.jwt,
            username: username
        )
        
        // MARK: - Save the account's credentials into the keychain
        
        AppKeychain.storage["\(newAccount.id)_accessToken"] = response.jwt
        
        // - TODO: Save `SavedAccount` info to persistent storage
        // Can we save all that info inside KeychainAccess?
        
        dismiss()
    }
    
    private func getUserID(authToken: String, instanceURL: URL) async throws -> Int {
        do {
            let request = try GetPersonDetailsRequest(
                accessToken: authToken,
                instanceURL: instanceURL,
                username: username
            )
            return try await APIClient()
                .perform(request: request)
                .personView
                .person
                .id
        } catch {
            print("getUserId Error info: \(error)")
            throw UserIDRetrievalError.couldNotFetchUserInformation
        }
    }
}

#Preview {
    AddAccountView()
}
