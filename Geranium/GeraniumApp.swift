//
//  GeraniumApp.swift
//  Andromeda
//
//  Developed by son3ra1n.
//

import SwiftUI

@main
struct GeraniumApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // TrollStore-only: this app calls CLSimulationManager
                    // (CoreLocation private CLSimulation framework) to move
                    // the device location. That requires the
                    // com.apple.locationd.simulation entitlement embedded by
                    // ldid at install time. If the entitlement is missing the
                    // simulation silently does nothing, so fail loudly here.
                    if isSandboxed() {
                        UIApplication.shared.alert(
                            title: "TrollStore Required",
                            body: "Location simulation needs the com.apple.locationd.simulation entitlement, which only a TrollStore (or otherwise unsandboxed) install provides."
                        )
                    }
                }
        }
    }
}

/// True when the process is confined to an app container, i.e. the
/// entitlements injected by TrollStore/ldid did not take effect.
func isSandboxed() -> Bool {
    let fm = FileManager.default
    let probe = "/var/mobile/locsim_sandbox_probe"
    fm.createFile(atPath: probe, contents: nil, attributes: nil)
    let confined = !fm.fileExists(atPath: probe)
    try? fm.removeItem(atPath: probe)
    return confined
}
