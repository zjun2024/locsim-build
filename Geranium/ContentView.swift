//
//  ContentView.swift
//  Andromeda
//
//  Developed by son3ra1n.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        // Single-module build: LocSim Pro is the only feature that ships.
        LocSimView()
            .tint(.indigo)
    }
}
