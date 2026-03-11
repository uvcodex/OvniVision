//
//  ContentView.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/9/26.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        AppNavigation {
            HomeScreen()
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
