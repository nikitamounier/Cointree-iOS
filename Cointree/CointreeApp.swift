//
//  CointreeApp.swift
//  Cointree
//
//  Created by Nikita Mounier on 02/09/2022.
//

import SwiftUI

@main
struct CointreeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            .environmentObject(CointreeViewModel())
        }
    }
}
