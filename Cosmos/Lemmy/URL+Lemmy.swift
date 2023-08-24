//
//  URL+Lemmy.swift
//  Cosmos
//
//  Created by Bosco Ho on 2023-08-24.
//

//  Adapted from:
//
//  Get Correct URL to Endpoint.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import Foundation

enum EndpointDiscoveryError: Error {
    case couldNotFindAnyCorrectEndpoints
    /// v1 is deprecated(?)
    case incompatibleVersion
}

extension URL {
    
    /// - Parameter lemmyInstance: For example: `lemmy.ca` or `www.lemmy.ml`, as long as the base address is valid.
    init?(lemmyInstance: String) async throws {
        /// Sanitize
        guard let match = lemmyInstance.firstMatch(of: /^(?:https?:\/\/)?(?:www\.)?(?:[\.\s]*)([^\/\?]+?)(?:[\.\s]*$|\/)/) else {
            return nil
        }
        
        let url = try await URL(instanceBaseAddress: String(match.output.1))
        guard url.path().contains("v1") == false else {
            throw EndpointDiscoveryError.incompatibleVersion
        }
        
        self = url
    }
    
    private init(instanceBaseAddress: String) async throws {
        var validAddress: URL?
        
#if targetEnvironment(simulator)
        let possibleInstanceAddresses = [
            URL(string: "https://\(instanceBaseAddress)/api/v3/user"),
            URL(string: "https://\(instanceBaseAddress)/api/v2/user"),
            URL(string: "https://\(instanceBaseAddress)/api/v1/user"),
            URL(string: "http://\(instanceBaseAddress)/api/v3/user"),
            URL(string: "http://\(instanceBaseAddress)/api/v2/user"),
            URL(string: "http://\(instanceBaseAddress)/api/v1/user")
        ]
            .compactMap { $0 }
#else
        let possibleInstanceAddresses = [
            URL(string: "https://\(instanceBaseAddress)/api/v3/user"),
            URL(string: "https://\(instanceBaseAddress)/api/v2/user"),
            URL(string: "https://\(instanceBaseAddress)/api/v1/user")
        ]
            .compactMap { $0 }
#endif
        
        for address in possibleInstanceAddresses {
            if await address.checkIfEndpointExists() {
                print("\(address) is valid")
                validAddress = address.deletingLastPathComponent()
                break
            } else {
                print("\(address) is invalid")
                continue
            }
        }
        
        if let validAddress {
            self = validAddress
        }
        
        throw EndpointDiscoveryError.couldNotFindAnyCorrectEndpoints
    }
    
    private func checkIfEndpointExists() async -> Bool {
        var request = URLRequest(url: self)
        request.httpMethod = "GET"
        
        do {
            let (_, response) = try await URLSession(configuration: .default).data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }
            return httpResponse.statusCode == 400
        } catch {
            return false
        }
    }
}
