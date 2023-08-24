//
//  CosmosApp.swift
//  Cosmos
//
//  Created by Bosco Ho on 2023-08-24.
//

import SwiftUI

@main
struct CosmosApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        .windowStyle(.titleBar)
        .windowToolbarStyle(.expanded)
        #endif
        #if os(macOS) || os(iOS)
        .commands {
            SidebarCommands()
        }
        #endif
    }
}
