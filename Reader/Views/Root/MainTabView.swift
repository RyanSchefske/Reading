//
//  MainTabView.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//

import SwiftUI

struct MainTabView: View {

    // MARK: - State

    @State private var selectedTab: Tab = .read

    // MARK: - Tab Enum

    enum Tab {
        case read
        case stats
        case history
        case settings
    }

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            // Read Tab
            NavigationStack {
                InputTextView()
            }
            .tabItem {
                Label("Read", systemImage: "book.fill")
            }
            .tag(Tab.read)

            // Stats Tab
            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(Tab.stats)

            // History Tab
            NavigationStack {
                ReadingHistoryView { text in
                    // Load text into input view
                    // For now, we'll need to handle this via a shared state
                }
            }
            .tabItem {
                Label("History", systemImage: "clock.fill")
            }
            .tag(Tab.history)

            // Settings Tab
            NavigationStack {
                SpeechSettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(Tab.settings)
        }
        .tint(.readerAccent)
    }
}

// MARK: - Previews

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
