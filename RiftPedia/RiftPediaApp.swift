//
//  RiftPediaApp.swift
//  RiftPedia
//
//  Created by Elyes Darouich on 23/11/2024.
//

import SwiftUI

@main
struct RiftPediaApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
