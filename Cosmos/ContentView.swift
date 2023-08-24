//
//  ContentView.swift
//  Cosmos
//
//  Created by Bosco Ho on 2023-08-24.
//

import SwiftUI

struct ContentView: View {
    
    /// The various constellations in our Fediverse.
    static let constellations: [String] = [
        "Lemmy",
        "Mastodon",
        "Kbin",
        "Pixelfed",
        "Firefish"
    ]
    
    static let identities: [String] = [
        "account id 1",
        "account id 2",
        "account id 3"
    ]
    
    @State private var constellation: String? = Self.constellations.first
    @State private var identity: String? = Self.identities.first
    
    var body: some View {
        NavigationSplitView {
            List(Self.constellations, id: \.self, selection: $constellation) {
                Text($0)
            }
            .listStyle(.sidebar)
            .navigationTitle("My Fediverse")
        } content: {
            List(Self.identities, id: \.self, selection: $identity) {
                Text($0)
            }
            .navigationTitle(constellation ?? "")
            #if os(macOS)
            .navigationSubtitle("My Identities")
            #endif
        } detail: {
            List {
                Text("some community")
            }
            .navigationTitle("Communities")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}
