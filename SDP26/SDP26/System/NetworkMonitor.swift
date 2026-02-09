//
//  NetworkMonitor.swift
//  SDP26
//
//  Monitors network connectivity status.
//

import Foundation
import Network

@Observable
final class NetworkMonitor {
    static let shared = NetworkMonitor()

    private(set) var isConnected = true
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
