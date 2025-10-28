//
//  ReaderApp.swift
//  Reader
//
//  Created by GPT Coding Assistant on 11/3/25.
//

import SwiftUI

@main
struct ReaderApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootContainerView()
        }
    }
}

