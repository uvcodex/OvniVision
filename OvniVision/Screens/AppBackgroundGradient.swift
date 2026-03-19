//
//  BackgroundGradient.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/19/26.
//

import SwiftUI

struct AppBackgroundGradient: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [Color(red: 0.05, green: 0.08, blue: 0.2), .black],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
}

extension View {
    func appBackgroundGradient() -> some View {
        modifier(AppBackgroundGradient())
    }
}

//#Preview {
//    BackgroundGradient()
//}
