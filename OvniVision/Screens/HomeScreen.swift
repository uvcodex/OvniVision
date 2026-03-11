//
//  HomeScreen.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/10/26.
//

import SwiftUI

struct HomeScreen: View {
    var body: some View {
        VStack {
            Text("Hello world")
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                AppLogo(width: 90)
            }
            .sharedBackgroundVisibility(.hidden)
        }
    }
}

#Preview {
    NavigationStack{
        HomeScreen()
    }
}
