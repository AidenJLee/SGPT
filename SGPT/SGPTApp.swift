//
//  SGPTApp.swift
//  SGPT
//
//  Created by HoJun Lee on 2023/03/03.
//

import SwiftUI

@main
struct SGPTApp: App {
    let persistenceController = PersistenceController.shared
    #warning("Your GPT key input here")
    static public let authenticationKey = "sk-xxxxxxxxxxxxxxxxxxxxxxx"
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
