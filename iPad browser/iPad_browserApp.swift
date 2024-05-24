//
//  iPad_browserApp.swift
//  iPad browser
//
//  Created by Caedmon Myers on 8/9/23.
//

import SwiftUI
import SwiftData
import CloudKit
import UIKit



class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    #if targetEnvironment(macCatalyst)
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        
        // Ensure this only runs on macOS
        guard builder.system == .main else { return }

        // Remove unwanted default menu items
        builder.remove(menu: .format)
        
        // Create custom menu actions
        let option1Action = UIAction(title: "Option 1", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off) { _ in
            self.handleOption1()
        }
        
        let option2Action = UIAction(title: "Option 2", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off) { _ in
            self.handleOption2()
        }

        // Create custom menu
        let customMenu = UIMenu(title: "Custom Menu", image: nil, identifier: UIMenu.Identifier("com.yourapp.custommenu"), options: [], children: [option1Action, option2Action])
        
        // Insert the custom menu into the main menu
        builder.insertSibling(customMenu, afterMenu: .help)
    }
    #endif
    
    @objc func handleOption1() {
        
    }
    
    @objc func handleOption2() {
        
    }
}





@main
struct iPad_browserApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        UserDefaults.standard.set(0, forKey: "selectedSpaceIndex")
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView()
                .onAppear { hideTitleBarOnCatalyst() }
        }
        .modelContainer(for: SpaceStorage.self, inMemory: false, isAutosaveEnabled: true, isUndoEnabled: true)
    }
    
    func hideTitleBarOnCatalyst() {
#if targetEnvironment(macCatalyst)
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.titlebar?.titleVisibility = .hidden
#endif
    }
}
