//
//  KeychainAccess.swift
//  Cosmos
//
//  Created by Bosco Ho on 2023-08-24.
//

import KeychainAccess

struct AppKeychain {
    static let keychainGroup: String = "com.boscoho.Cosmos"
    static let storage: Keychain = .init(service: "\(keychainGroup)-keychain")
}
